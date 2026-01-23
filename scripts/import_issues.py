#!/usr/bin/env python3
"""
Import GitHub Issues from Markdown Sprint Files

Usage:
  python3 import_issues.py --repo OWNER/REPO --file PATH [--project NUMBER] [--dry-run]

Examples:
  # Dry run - preview only
  python3 import_issues.py --repo Hybro-Tech/ankhang-crm --file docs/planning/sprints/sprint-1-foundation.md --dry-run

  # Create issues only
  python3 import_issues.py --repo Hybro-Tech/ankhang-crm --file docs/planning/sprints/sprint-1-foundation.md

  # Create issues AND add to project
  python3 import_issues.py --repo Hybro-Tech/ankhang-crm --file docs/planning/sprints/sprint-1-foundation.md --project 1
"""

import re
import subprocess
import argparse
import sys
import shutil
import json


def check_gh_installed():
    """Check if gh CLI is installed and authenticated."""
    if not shutil.which("gh"):
        print("❌ Error: GitHub CLI ('gh') is not installed.")
        print("   Install: https://cli.github.com/")
        return False
    
    try:
        subprocess.run(["gh", "auth", "status"], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    except subprocess.CalledProcessError:
        print("❌ Error: Not logged in to GitHub CLI.")
        print("   Run: gh auth login")
        return False
    return True


def get_existing_issues(repo):
    """Get dict of existing issue titles to issue numbers."""
    try:
        cmd = ["gh", "issue", "list", "--repo", repo, "--limit", "500", "--state", "all", "--json", "title,number,url"]
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        issues = json.loads(result.stdout)
        return {issue['title']: {'number': issue['number'], 'url': issue['url']} for issue in issues}
    except (subprocess.CalledProcessError, json.JSONDecodeError):
        return {}


def get_existing_labels(repo):
    """Get list of existing labels in the repo using gh api."""
    try:
        cmd = ["gh", "api", f"/repos/{repo}/labels", "--jq", ".[].name"]
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        return set(result.stdout.strip().split('\n')) if result.stdout.strip() else set()
    except subprocess.CalledProcessError:
        return set()


def create_label(repo, name, dry_run=False):
    """Create a label in the repo with appropriate color using gh api."""
    # Define colors for different label types
    colors = {
        'priority:critical': 'B60205',  # Red
        'priority:high': 'D93F0B',      # Orange
        'priority:medium': 'FBCA04',     # Yellow
        'priority:low': '0E8A16',        # Green
        'priority:normal': 'C2E0C6',     # Light green
    }
    
    # Epic labels get blue color
    if name.startswith('epic:'):
        color = '0052CC'  # Blue
    else:
        color = colors.get(name, 'EDEDED')  # Default gray
    
    if dry_run:
        print(f"   [DRY RUN] Would create label: {name}")
        return True
    
    try:
        # Use gh api to create label (works with all gh versions)
        cmd = [
            "gh", "api",
            f"/repos/{repo}/labels",
            "-X", "POST",
            "-f", f"name={name}",
            "-f", f"color={color}",
            "-f", f"description=Auto-created by import script"
        ]
        subprocess.run(cmd, capture_output=True, text=True, check=True)
        return True
    except subprocess.CalledProcessError:
        return False


def ensure_labels_exist(repo, tasks, dry_run=False):
    """Ensure all required labels exist in the repo."""
    # Collect all unique labels from tasks
    required_labels = set()
    for task in tasks:
        for label in task['labels']:
            required_labels.add(label)
    
    if not required_labels:
        return
    
    print(f"\n🏷️  Checking labels...")
    
    existing_labels = set()
    if not dry_run:
        existing_labels = get_existing_labels(repo)
    
    missing_labels = required_labels - existing_labels
    
    if missing_labels:
        print(f"   Creating {len(missing_labels)} missing labels...")
        for label in sorted(missing_labels):
            if create_label(repo, label, dry_run):
                print(f"   ✓ Created: {label}")
            else:
                print(f"   ⚠ Failed to create: {label}")
    else:
        print(f"   ✓ All {len(required_labels)} labels exist")


def add_to_project(issue_url, project_number, owner, dry_run=False):
    """Add an issue to a GitHub Project using GraphQL API."""
    if dry_run:
        print(f"   [DRY RUN] Would add to project #{project_number}")
        return True
    
    # Extract issue node ID from issue URL using API
    try:
        # First, get the issue node ID
        parts = issue_url.rstrip('/').split('/')
        issue_number = parts[-1]
        repo_name = parts[-3]
        repo_owner = parts[-4]
        
        # Get issue node ID
        get_issue_cmd = [
            "gh", "api", f"/repos/{repo_owner}/{repo_name}/issues/{issue_number}",
            "--jq", ".node_id"
        ]
        result = subprocess.run(get_issue_cmd, capture_output=True, text=True, check=True)
        issue_node_id = result.stdout.strip()
        
        # Get project node ID using GraphQL
        graphql_query = f'''
        query {{
          organization(login: "{owner}") {{
            projectV2(number: {project_number}) {{
              id
            }}
          }}
        }}
        '''
        
        # Try organization first
        get_project_cmd = ["gh", "api", "graphql", "-f", f"query={graphql_query}"]
        result = subprocess.run(get_project_cmd, capture_output=True, text=True)
        
        project_id = None
        if result.returncode == 0:
            import json
            data = json.loads(result.stdout)
            if data.get('data', {}).get('organization', {}).get('projectV2'):
                project_id = data['data']['organization']['projectV2']['id']
        
        # If not found in org, try user
        if not project_id:
            graphql_query = f'''
            query {{
              user(login: "{owner}") {{
                projectV2(number: {project_number}) {{
                  id
                }}
              }}
            }}
            '''
            get_project_cmd = ["gh", "api", "graphql", "-f", f"query={graphql_query}"]
            result = subprocess.run(get_project_cmd, capture_output=True, text=True)
            
            if result.returncode == 0:
                import json
                data = json.loads(result.stdout)
                if data.get('data', {}).get('user', {}).get('projectV2'):
                    project_id = data['data']['user']['projectV2']['id']
        
        if not project_id:
            print(f"   ⚠ Project #{project_number} not found")
            return False
        
        # Add issue to project using GraphQL mutation
        mutation = f'''
        mutation {{
          addProjectV2ItemById(input: {{
            projectId: "{project_id}"
            contentId: "{issue_node_id}"
          }}) {{
            item {{
              id
            }}
          }}
        }}
        '''
        
        add_cmd = ["gh", "api", "graphql", "-f", f"query={mutation}"]
        result = subprocess.run(add_cmd, capture_output=True, text=True, check=True)
        print(f"   ✓ Added to project #{project_number}")
        return True
        
    except subprocess.CalledProcessError as e:
        print(f"   ⚠ Failed to add to project (feature requires newer gh or project access)")
        return False
    except Exception as e:
        print(f"   ⚠ Failed to add to project: {str(e)}")
        return False


def parse_markdown(file_path, include_done=False):
    """Parse markdown file and extract tasks."""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Tasks start with ### TASK-XXX: Title or ### TASK-XXX-A: Title
    task_pattern = re.compile(r'### (TASK-\d+(?:-[A-Z])?): (.+)')
    
    tasks = []
    matches = list(task_pattern.finditer(content))
    
    for i, match in enumerate(matches):
        task_id = match.group(1)
        task_title = match.group(2).strip()
        
        start_index = match.end()
        end_index = matches[i+1].start() if i + 1 < len(matches) else len(content)
        
        task_body_raw = content[start_index:end_index].strip()
        
        # Parse fields from the table
        priority = "Normal"
        epic = ""
        story_points = ""
        status = ""
        
        priority_match = re.search(r'\|\s*\*\*Priority\*\*\s*\|\s*(.+?)\s*\|', task_body_raw)
        if priority_match:
            p_val = priority_match.group(1).strip()
            if "Critical" in p_val: priority = "Critical"
            elif "High" in p_val: priority = "High"
            elif "Medium" in p_val: priority = "Medium"
            elif "Low" in p_val: priority = "Low"
            
        epic_match = re.search(r'\|\s*\*\*Epic\*\*\s*\|\s*(.+?)\s*\|', task_body_raw)
        if epic_match:
            epic = epic_match.group(1).strip()

        sp_match = re.search(r'\|\s*\*\*Story Points\*\*\s*\|\s*(.+?)\s*\|', task_body_raw)
        if sp_match:
            story_points = sp_match.group(1).strip()
            
        status_match = re.search(r'\|\s*\*\*Status\*\*\s*\|\s*(.+?)\s*\|', task_body_raw)
        if status_match:
            status = status_match.group(1).strip()
            
        # Skip done tasks unless include_done is True
        if status.lower() == "done" and not include_done:
            continue
            
        # Clean up body: Remove the metadata table
        clean_body_lines = []
        for line in task_body_raw.split('\n'):
            if line.strip().startswith('|'):
                continue
            clean_body_lines.append(line)
        
        clean_body = '\n'.join(clean_body_lines).strip()
        
        # Remove trailing "---" if present
        clean_body = re.sub(r'\n---.*', '', clean_body, flags=re.DOTALL).strip()
        
        full_title = f"[{task_id}] {task_title}"
        
        labels = []
        if priority:
            labels.append(f"priority:{priority.lower()}")
        if epic:
            labels.append(f"epic:{epic.replace(' ', '-').lower()}")
        
        # Add Story Points to body as metadata
        extra_meta = []
        if story_points:
            extra_meta.append(f"**Story Points**: {story_points}")
        if epic:
            extra_meta.append(f"**Epic**: {epic}")
            
        final_body = f"{clean_body}\n\n---\n" + " | ".join(extra_meta)
        
        tasks.append({
            'id': task_id,
            'title': full_title,
            'body': final_body,
            'labels': labels
        })
        
    return tasks


def create_gh_issue(task, repo, project=None, owner=None, dry_run=False):
    """Create a GitHub issue and optionally add to project."""
    cmd = [
        "gh", "issue", "create",
        "--repo", repo,
        "--title", task['title'],
        "--body", task['body'],
    ]
    
    for label in task['labels']:
        cmd.extend(["--label", label])
        
    if dry_run:
        print(f"\n[DRY RUN] CREATE: {task['title']}")
        print(f"   Repo: {repo}")
        print(f"   Labels: {', '.join(task['labels'])}")
        if project:
            add_to_project("", project, owner, dry_run=True)
        return True, None
    
    print(f"\n📝 Creating: {task['title']}...")
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        issue_url = result.stdout.strip()
        print(f"   ✓ Created: {issue_url}")
        
        # Add to project if specified
        if project and owner:
            add_to_project(issue_url, project, owner, dry_run=False)
        
        return True, issue_url
    except subprocess.CalledProcessError as e:
        print(f"   ❌ Error: {e.stderr.strip()}")
        return False, None


def update_gh_issue(task, repo, issue_number, issue_url, project=None, owner=None, dry_run=False):
    """Update an existing GitHub issue."""
    if dry_run:
        print(f"\n[DRY RUN] UPDATE: {task['title']} (#{issue_number})")
        print(f"   Labels: {', '.join(task['labels'])}")
        if project:
            add_to_project("", project, owner, dry_run=True)
        return True
    
    print(f"\n🔄 Updating: {task['title']} (#{issue_number})...")
    try:
        # Update body
        cmd = [
            "gh", "issue", "edit", str(issue_number),
            "--repo", repo,
            "--body", task['body'],
        ]
        subprocess.run(cmd, capture_output=True, text=True, check=True)
        
        # Update labels (add new ones)
        for label in task['labels']:
            label_cmd = [
                "gh", "issue", "edit", str(issue_number),
                "--repo", repo,
                "--add-label", label
            ]
            subprocess.run(label_cmd, capture_output=True, text=True)
        
        print(f"   ✓ Updated: {issue_url}")
        
        # Add to project if specified
        if project and owner:
            add_to_project(issue_url, project, owner, dry_run=False)
        
        return True
    except subprocess.CalledProcessError as e:
        print(f"   ❌ Error: {e.stderr.strip()}")
        return False


def main():
    parser = argparse.ArgumentParser(
        description='Import GitHub Issues from Markdown Sprint Files',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s --repo Hybro-Tech/ankhang-crm --file sprint-1.md --dry-run
  %(prog)s --repo Hybro-Tech/ankhang-crm --file sprint-1.md --project 1
  %(prog)s --repo Hybro-Tech/ankhang-crm --file sprint-1.md --update
        """
    )
    parser.add_argument('--repo', required=True, 
                        help='Target GitHub repo (e.g., Hybro-Tech/ankhang-crm)')
    parser.add_argument('--file', required=True, 
                        help='Path to markdown file with tasks')
    parser.add_argument('--project', type=int, 
                        help='GitHub Project number to add issues to (optional)')
    parser.add_argument('--update', action='store_true',
                        help='Update existing issues instead of skipping')
    parser.add_argument('--include-done', action='store_true',
                        help='Include tasks with Status: Done')
    parser.add_argument('--dry-run', action='store_true', 
                        help='Preview actions without executing')
    
    args = parser.parse_args()
    
    # Extract owner from repo
    owner = args.repo.split('/')[0] if '/' in args.repo else None
    
    print("=" * 60)
    print("📋 GitHub Issues Importer")
    print("=" * 60)
    print(f"📁 File: {args.file}")
    print(f"🏠 Repo: {args.repo}")
    if args.project:
        print(f"📊 Project: #{args.project}")
    if args.update:
        print("🔄 Mode: UPDATE (will update existing issues)")
    if args.include_done:
        print("✅ Mode: INCLUDE DONE (will import done tasks)")
    if args.dry_run:
        print("🔍 Mode: DRY RUN (no changes will be made)")
    print("=" * 60)
    
    if not args.dry_run:
        if not check_gh_installed():
            sys.exit(1)
            
    # Parse tasks
    try:
        tasks = parse_markdown(args.file, include_done=args.include_done)
    except FileNotFoundError:
        print(f"❌ Error: File not found: {args.file}")
        sys.exit(1)
        
    done_msg = "" if args.include_done else " (excluding Done)"
    print(f"\n📋 Found {len(tasks)} tasks{done_msg}")
    
    # Ensure all labels exist
    ensure_labels_exist(args.repo, tasks, dry_run=args.dry_run)
    
    # Check for existing issues
    existing_issues = {}
    if not args.dry_run:
        print("\n🔍 Checking for existing issues...")
        existing_issues = get_existing_issues(args.repo)
        print(f"   Found {len(existing_issues)} existing issues")
    
    created = 0
    updated = 0
    skipped = 0
    failed = 0
    
    for task in tasks:
        if task['title'] in existing_issues:
            if args.update:
                # Update existing issue
                issue_info = existing_issues[task['title']]
                if update_gh_issue(
                    task,
                    repo=args.repo,
                    issue_number=issue_info['number'],
                    issue_url=issue_info['url'],
                    project=args.project,
                    owner=owner,
                    dry_run=args.dry_run
                ):
                    updated += 1
                else:
                    failed += 1
            else:
                print(f"\n⏭️  [SKIP] Already exists: {task['title']}")
                skipped += 1
            continue
            
        success, _ = create_gh_issue(
            task, 
            repo=args.repo, 
            project=args.project,
            owner=owner,
            dry_run=args.dry_run
        )
        if success:
            created += 1
        else:
            failed += 1
    
    print("\n" + "=" * 60)
    print("📊 Summary")
    print("=" * 60)
    print(f"   ✅ Created: {created}")
    print(f"   🔄 Updated: {updated}")
    print(f"   ⏭️  Skipped: {skipped}")
    print(f"   ❌ Failed:  {failed}")
    print("=" * 60)


if __name__ == "__main__":
    main()
