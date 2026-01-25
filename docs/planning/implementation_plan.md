# Implementation Plan - Sync Sprint Tasks to GitHub

## Goal
Automate the creation of GitHub Issues from the markdown sprint plan (`docs/planning/sprints/sprint-1-foundation.md`) using the GitHub CLI (`gh`).

## User Review Required
> [!IMPORTANT]
> This script requires the `gh` CLI to be authenticated. I will assume it is already set up in your environment.
> The script will attempt to create issues. I will implement a `--dry-run` flag by default to show what would happen without actually creating issues.

## Proposed Changes

### Scripts
#### [NEW] [sync_tasks_to_github.py](file:///wsl.localhost/Ubuntu/home/david/work/ankhang-crm/scripts/sync_tasks_to_github.py)
A Python script that:
1.  Reads the specified markdown file.
2.  Parses tasks starting with `### TASK-XXX`.
3.  Extracts:
    -   **Title**: `TASK-XXX: Task Name`
    -   **Body**: Combines User Story, Description, Acceptance Criteria, and Test Cases.
    -   **Labels**: Maps `Priority` (Critical -> `priority:critical`, High -> `priority:high`).
    -   **Status**: checks if "Status" is "Done" (if so, maybe skip or create as closed).
4.  Uses `gh issue list` to check if `TASK-XXX` already exists to avoid duplicates.
5.  Uses `gh issue create` to create new issues.

## Verification Plan

### Automated
-   Run the script with `--dry-run` on `docs/planning/sprints/sprint-1-foundation.md` and check the output.
    ```bash
    python3 scripts/sync_tasks_to_github.py docs/planning/sprints/sprint-1-foundation.md --dry-run
    ```

### Manual
-   After verifying dry run, execute the script for real (upon user confirmation).
-   Check GitHub Issues list to verify creation.
