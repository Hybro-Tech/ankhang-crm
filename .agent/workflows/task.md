---
description: Execute a specific task (e.g., TASK-009) while strictly adhering to all project rules, skills, and governance protocols.
---

# /task - Strict Task Execution

$ARGUMENTS

---

## Purpose

This workflow ensures that any requested task is executed with **zero compromise** on project standards. It forces the AI to explicitly load and apply the rules effectively acting as a "Governance Wrapper" around the work.

---

## Workflow Steps

### 1. 🛡️ Governance & Protocol Check (CRITICAL)

**Before doing anything else**, you must:

1. **Read `.antigravityrules`**: 
   - Ensure you are aware of the project-specific constraints and preferences.
   - `view_file .antigravityrules`

2. **Read Master Agent Rules (`.agent/*.md`)**:
   - Identify the primary agent for this task (e.g., Backend, Frontend, or Mobile).
   - Read their specific governance file.

3. **Identify & Load Skills**:
   - Based on the task description, select relevant skills from `.agent/skills/`.
   - **MANDATORY**: You must read the `SKILL.md` of any skill you intend to use.

---

### 2. 📋 Task Analysis (The "Socratic Gate")

**Input**: User says "Do Task 009" or "Build feature X".

1. **Search for Task Context**:
   - `grep_search "TASK-009" .` (or the relevant task ID).
   - Look for requirements in `docs/` or existing `task.md`.

2. **Verify Clarity**:
   - Do you understand the *Goal*, *Scope*, and *Success Criteria*?
   - If NO -> Ask clarifying questions (Use `notify_user`).
   - If YES -> Proceed to planning.

---

### 3. 📝 Planning & Architecture

1. **Create/Update `task.md`**:
   - Break down the work into checklist items.
   - Map each item to a specific Rule or Skill it must satisfy.

2. **Select Tech Stack & Patterns**:
   - **Backend**: Rails 7.1, RSpec, Sidekiq, etc.
   - **Frontend**: Hotwire, Stimulus, Tailwind.
   - **Design**: Must match `ui-ux-pro-max` standards.

---

### 4. ⚙️ Execution (Iterative)

**For every code change:**

1. **Apply Standards**:
   - **Naming**: Strict naming conventions.
   - **Formatting**: Standard indentation and style.
   - **Security**: No hardcoded secrets, check permissions (CanCanCan).

2. **Self-Correction**:
   - Before saving a file, ask: *"Does this violate any rule in .antigravityrules?"*
   - If yes, fix it immediately.

---

### 5. ✅ Verification & Closure

1. **Run Tests**:
   - `bundle exec rspec` (Logic)
   - `bundle exec rubocop` (Linting)

2. **Final Rule Check**:
   - Review the changes against the `.antigravityrules` one last time.

3. **Update Status**:
   - Mark task artifacts as complete.
   - Report summary to user.

---

## Usage Examples

```
/task TASK-009
/task Implement User Login flow
/task Refactor the Journal module
```
