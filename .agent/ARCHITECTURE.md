# AnKhangCRM Agent Architecture

> **Customized for Ruby on Rails 7+** | AnKhangCRM Project

---

## 📋 Overview

Agent configuration optimized for:
- **Ruby on Rails 7+** backend
- **Hotwire (Turbo + Stimulus)** frontend
- **MySQL 8+** database
- **Sidekiq + Redis** background jobs

---

## 🏗️ Directory Structure

```
.agent/
├── ARCHITECTURE.md          # This file
├── agents/                  # 16 Specialist Agents
├── skills/                  # Domain-specific skills
│   ├── .archived/           # Archived JS/TS skills
│   └── ...
├── workflows/               # 11 Slash Commands
└── rules/                   # Global Rules (GEMINI.md)
```

---

## 🎯 Rails-Specific Skills (NEW)

| Skill | Description |
|-------|-------------|
| `rails-patterns` | MVC, ActiveRecord, Concerns, Service Objects |
| `hotwire-turbo` | Turbo Frames, Turbo Streams, Stimulus |
| `rspec-patterns` | BDD testing, FactoryBot, System specs |
| `devise-auth` | Authentication, session management |
| `cancancan-rbac` | Dynamic RBAC, permission matrix |
| `sidekiq-jobs` | Background jobs, scheduling |
| `mysql-optimization` | Indexing, query optimization |

---

## ✅ Active Skills

### Ruby on Rails
| Skill | Description |
|-------|-------------|
| `rails-patterns` | MVC, Service Objects |
| `hotwire-turbo` | Turbo, Stimulus |
| `rspec-patterns` | RSpec testing |
| `devise-auth` | Devise authentication |
| `cancancan-rbac` | CanCanCan authorization |
| `sidekiq-jobs` | Background processing |
| `mysql-optimization` | Database performance |

### Frontend
| Skill | Description |
|-------|-------------|
| `tailwind-patterns` | Tailwind CSS v4 |
| `frontend-design` | UI/UX patterns |

### Universal
| Skill | Description |
|-------|-------------|
| `clean-code` | Coding standards (Global) |
| `api-patterns` | REST principles |
| `database-design` | Schema design |
| `testing-patterns` | Testing pyramid |
| `vulnerability-scanner` | OWASP security |
| `brainstorming` | Socratic questioning |
| `plan-writing` | Task planning |
| `architecture` | System design |
| `deployment-procedures` | Deploy workflows |
| `docker-expert` | Containerization |

---

## 📦 Archived Skills

Moved to `.archived/` (not loaded):
- `react-patterns`
- `nextjs-best-practices`
- `prisma-expert`
- `nestjs-expert`
- `typescript-expert`

---

## 🔄 Workflows

| Command | Description |
|---------|-------------|
| `/brainstorm` | Socratic discovery |
| `/plan` | Task breakdown |
| `/create` | Create features |
| `/debug` | Debug issues |
| `/test` | Run tests |
| `/deploy` | Deploy application |

---

## 🔗 Quick Reference

| Task | Skills |
|------|--------|
| New Controller | rails-patterns |
| Turbo UI | hotwire-turbo |
| Tests | rspec-patterns |
| Auth | devise-auth |
| Permissions | cancancan-rbac |
| Background Job | sidekiq-jobs |
| DB Query | mysql-optimization |
| Styling | tailwind-patterns |
| Security | vulnerability-scanner |
