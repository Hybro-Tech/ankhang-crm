---
description: Deployment command for production releases. Pre-flight checks and deployment execution for Rails apps.
---

# /deploy - Production Deployment (Rails)

$ARGUMENTS

---

## Purpose

This command handles production deployment with pre-flight checks, deployment execution, and verification for the Ruby on Rails application.

---

## Sub-commands

```
/deploy            - Interactive deployment wizard
/deploy check      - Run pre-deployment checks only
/deploy preview    - Deploy to staging/preview
/deploy production - Deploy to production
/deploy rollback   - Rollback to previous version
```

---

## Pre-Deployment Checklist

Before any deployment:

```markdown
## 🚀 Pre-Deploy Checklist

### Code Quality
- [ ] No Rubocop offenses (`bundle exec rubocop`)
- [ ] All RSpec tests passing (`bundle exec rspec`)
- [ ] No Pending Migrations (`bundle exec rails db:migrate:status`)

### Security
- [ ] Dependencies audited (`bundle audit`)
- [ ] Master Key present (if using credentials)
- [ ] Environment variables documented (.env.example)

### Performance
- [ ] Assets precompiled locally (optional verification)
- [ ] Database indexes reviewed
- [ ] N+1 queries checked (Bullet)

### Documentation
- [ ] README updated
- [ ] CHANGELOG updated
- [ ] API docs current

### Ready to deploy? (y/n)
```

---

## Deployment Flow

```
┌─────────────────┐
│  /deploy        │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Pre-flight     │
│  checks         │
└────────┬────────┘
         │
    Pass? ──No──► Fix issues
         │
        Yes
         │
         ▼
┌─────────────────┐
│  Build          │
│  Docker Image   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Push &         │
│  Migrate DB     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Health check   │
│  & verify       │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  ✅ Complete    │
└─────────────────┘
```

---

## Output Format

### Successful Deploy

```markdown
## 🚀 Deployment Complete

### Summary
- **Version:** v1.2.3 (Git SHA)
- **Environment:** production
- **Duration:** 2 mins 15s
- **Platform:** Docker / Kamal / Cloud

### Status
- 🌐 Application: Online (200 OK)
- 🗄️ Database: Migrated
- 🔄 Background Jobs: Sidekiq Running

### What Changed
- Added User Authentication
- Fixed Invoice Generation bug
- Updated Gems

### Health Check
✅ Homepage accessible
✅ Asset host reachable
✅ Redis connected
```

### Failed Deploy

```markdown
## ❌ Deployment Failed

### Error
Migration failed at step: 20240120120000_create_users.rb

### Details
```
StandardError: An error has occurred, this and all later migrations canceled:
Mysql2::Error: Table 'users' already exists
```

### Resolution
1. Check database state
2. Fix migration file
3. Run `/deploy` again

### Rollback Available
Previous image is tagged `lawcrm:previous`.
Run `/deploy rollback` to revert.
```

---

## Platform Support

| Platform | Command | Notes |
|----------|---------|-------|
| Docker (Generic) | `docker compose up -d --build` | For single server VPS |
| Kamal | `kamal deploy` | Recommended for multi-server |
| Heroku | `git push heroku main` | Using Ruby buildpack |
| Render | `git push render main` | Auto-deploy |

---

## Examples

```
/deploy
/deploy check
/deploy production --skip-tests
/deploy rollback
```
