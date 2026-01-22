---
description: Code Refactoring Workflow. Improves structure, performance, and readability without changing behavior.
---

# /refactor - Code Improvement Strategy

$ARGUMENTS

---

## Purpose

This command initiates a safe, systematic refactoring process for a specific file, module, or pattern. It focuses on cleaning technical debt, optimizing N+1 queries, and applying design patterns (e.g., Service Objects, ViewComponents).

---

## Sub-commands

```
/refactor [file]           - Refactor a specific file
/refactor pattern [name]   - Apply a pattern (e.g., /refactor pattern service)
/refactor performance      - Optimize for speed (N+1, Indexes)
/refactor dry              - Reduce duplication across files
```

---

## Workflow Steps

### 1. 🔍 Analysis

1. **Read Code**: Understand the existing logic using `view_file`.
2. **Identify Smells**:
   - Long methods (> 20 lines)
   - Fat Controllers
   - N+1 Queries (Look for loops accessing associations)
   - Complex Conditionals (Nested `if/else`)
   - Hardcoded values
   - Duplicated logic (DRY)

### 2. 🛡️ Safety Net

1. **Check Tests**: Are there existing tests?
   - **YES result**: Run them `bundle exec rspec [file_spec.rb]` to establish baseline.
   - **NO result**: **STOP**. Create a "Characterization Test" (snapshot test) first to ensure behavior doesn't change.

### 3. 🛠️ Execution Strategy

Apply specific transformations based on the smell:

#### A. Extract Service Object
*For Fat Controllers or complex business logic.*
1. Create `app/services/[domain]/[action]_service.rb`.
2. Move logic to `call` method.
3. Replace controller code with service call.

#### B. Extract ViewComponent
*For complex partials or repeated logic in views.*
1. Create `app/components/[name]_component.rb`.
2. Move HTML to component template.
3. Replace `render partial:` with `render component`.

#### C. Optimize Queries
*For N+1 or slow implementation.*
1. Analyze query plan.
2. Add `.includes()`, `.preload()`, or `counter_cache`.
3. Verify in console.

### 4. ✅ Verification

1. **Run Tests Again**: Ensure ALL tests pass.
2. **Lint Check**: Run `bundle exec rubocop [file]`.
3. **Diff Review**: Check `render_diffs` to confirm changes are structural only.

---

## Example Scenarios

### 1. Refactor Controller
**User**: "/refactor app/controllers/orders_controller.rb"
**Action**: Move the 50-line `create` method into `OrderCreatorService`.

### 2. DRY up Views
**User**: "/refactor duplication in admin views"
**Action**: Extract the repeating table logic into `Ui::TableComponent`.

### 3. Fix Performance
**User**: "/refactor performance"
**Action**: Scan log for N+1 alerts and add `.includes(:user)` to `PostsController`.
