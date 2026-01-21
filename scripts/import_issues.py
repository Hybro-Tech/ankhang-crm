import re
import subprocess
import argparse
import sys
import shutil

def check_gh_installed():
    """Check if gh CLI is installed and authenticated."""
    if not shutil.which("gh"):
        print("Error: GitHub CLI ('gh') is not installed. Please install it first.")
        return False
    
    try:
        subprocess.run(["gh", "auth", "status"], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    except subprocess.CalledProcessError:
        print("Error: You are not logged in to GitHub CLI. Run 'gh auth login'.")
        return False
    return True

def parse_markdown(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Split by task header
    # Tasks start with ### TASK-XXX: Title
    task_pattern = re.compile(r'### (TASK-\d+): (.+)')
    
    tasks = []
    lines = content.split('\n')
    current_task = None
    
    formatted_lines = []
    
    # Simple state machine to capture task blocks
    # We'll split by "### TASK-" but we need to keep the content
    
    chunks = re.split(r'(^### TASK-\d+: .+)', content, flags=re.MULTILINE)
    
    # First chunk is prelude (headers, tables), skip it or handle it? 
    # Actually, let's just iterate over matches.
    
    # Find all start indices
    matches = list(task_pattern.finditer(content))
    
    for i, match in enumerate(matches):
        task_id = match.group(1)
        task_title = match.group(2).strip()
        
        start_index = match.end()
        end_index = matches[i+1].start() if i + 1 < len(matches) else len(content)
        
        task_body_raw = content[start_index:end_index].strip()
        
        # Parse fields from the table
        # | **Story Points** | 3 |
        # | **Priority** | 🔴 Critical |
        # | **Epic** | Project Setup |
        
        priority = "Normal"
        epic = ""
        story_points = ""
        
        priority_match = re.search(r'\|\s*\*\*Priority\*\*\s*\|\s*(.+?)\s*\|', task_body_raw)
        if priority_match:
            p_val = priority_match.group(1).strip()
            # Map simplified priority
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
            
        # Clean up body: Remove the metadata table
        # We can detect the end of the table (usually a blank line or headers)
        # But a simple way is to remove lines starting with | (pipe)
        
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
            'title': full_title,
            'body': final_body,
            'labels': labels
        })
        
    return tasks

def create_gh_issue(task, dry_run=False):
    cmd = [
        "gh", "issue", "create",
        "--title", task['title'],
        "--body", task['body'],
    ]
    
    for label in task['labels']:
        cmd.extend(["--label", label])
        
    if dry_run:
        print(f"[DRY RUN] Would execute: {' '.join(cmd)}")
        print(f"Title: {task['title']}")
        print(f"Labels: {task['labels']}")
        print("-" * 40)
        return True
    
    print(f"Creating issue: {task['title']}...")
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        print(f"Success: {result.stdout.strip()}")
        return True
    except subprocess.CalledProcessError as e:
        print(f"Error creating issue '{task['title']}': {e.stderr}")
        return False

def main():
    parser = argparse.ArgumentParser(description='Import issues from markdown to GitHub.')
    parser.add_argument('--file', default='docs/planning/sprints/all_tasks_backlog.md', help='Path to backlog markdown file')
    parser.add_argument('--dry-run', action='store_true', help='Preview actions without executing')
    
    args = parser.parse_args()
    
    if not args.dry_run:
        if not check_gh_installed():
            sys.exit(1)
            
    print(f"Parsing {args.file}...")
    try:
        tasks = parse_markdown(args.file)
    except FileNotFoundError:
        print(f"Error: File {args.file} not found.")
        sys.exit(1)
        
    print(f"Found {len(tasks)} tasks.")
    
    for task in tasks:
        create_gh_issue(task, dry_run=args.dry_run)

if __name__ == "__main__":
    main()
