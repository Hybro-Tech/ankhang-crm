# 📋 Remaining Tasks - Priority Order

> **Updated:** 2026-02-04
> **Total:** 23 tasks | ~74 SP | ~3-4 weeks

---

## 🔴 PHASE 1: Sprint 6 Core (Database + Logic)

| # | Task | Mô tả | SP | Status |
|---|------|-------|-----|--------|
| 1 | TASK-060 | Remove Pick Rules từ ServiceType | 2 | [x] |
| 2 | TASK-064 | Simplify Contact Status (10→4) | 5 | [ ] |
| 3 | TASK-065 | ENV PICK_COOLDOWN_MINUTES | 1 | [ ] |
| 4 | TASK-067 | Update PickEligibilityService | 3 | [ ] |

---

## 🟠 PHASE 2: Sprint 6 Province

| # | Task | Mô tả | SP | Status |
|---|------|-------|-----|--------|
| 5 | TASK-061 | Provinces & ProvinceRegions Tables | 3 | [ ] |
| 6 | TASK-063 | Add Province to Contact | 2 | [ ] |
| 7 | TASK-068 | Province CRUD Admin | 3 | [ ] |
| 8 | TASK-069 | Region → Provinces Selection | 3 | [ ] |
| 9 | TASK-071 | Call Center Province Dropdown | 2 | [ ] |

---

## 🟡 PHASE 3: Sprint 6 Routing

| # | Task | Mô tả | SP | Status |
|---|------|-------|-----|--------|
| 10 | TASK-066 | Refactor SmartRouting (3 Layers) | 8 | [ ] |

---

## 🟢 PHASE 4: Sprint 4 Email + Sprint 7 CSKH

| # | Task | Mô tả | SP | Status |
|---|------|-------|-----|--------|
| 11 | TASK-033 | Email Notifications | 3 | [ ] |
| 12 | TASK-076 | Setting max_appointment_days | 1 | [ ] |
| 13 | TASK-072 | CSKH Workspace Layout | 3 | [ ] |
| 14 | TASK-073 | Blacklist Tab | 3 | [ ] |
| 15 | TASK-074 | CSKH "Cướp khách" Action | 5 | [ ] |
| 16 | TASK-075 | Inspection Tab | 3 | [ ] |

---

## 🔵 PHASE 5: Sprint 7 ZNS

| # | Task | Mô tả | SP | Status |
|---|------|-------|-----|--------|
| 17 | TASK-077 | ZNS Auto Send Job | 5 | [ ] |
| 18 | TASK-078 | ZNS Manual Send UI | 5 | [ ] |
| 19 | TASK-079 | ZNS Log & History | 3 | [ ] |

---

## ⚫ PHASE 6: Deploy (Cần server info)

| # | Task | Mô tả | SP | Status |
|---|------|-------|-----|--------|
| 20 | TASK-044 | Production Server Setup | 5 | [ ] |
| 21 | TASK-045 | Backup & Monitoring | 3 | [ ] |
| 22 | TASK-046 | Documentation & Handover | 3 | [ ] |

---

## 🟣 BACKLOG (Có thể defer)

| # | Task | Mô tả | SP | Status |
|---|------|-------|-----|--------|
| 23 | TASK-052 | Admin Re-assign Approval Workflow | 8 | [ ] |

---

## 📊 Dependency Graph

```
PHASE 1 (Core)
TASK-060 ─┬─► TASK-064 (status)
          ├─► TASK-065 (ENV)
          └─► TASK-067 (eligibility)

PHASE 2 (Province)
TASK-060 ─► TASK-061 ─┬─► TASK-063 ─► TASK-071
                      └─► TASK-068 ─► TASK-069

PHASE 3 (Routing)
TASK-065 + TASK-067 ─► TASK-066

PHASE 4 (CSKH)
Sprint 6 ─► TASK-072 ─┬─► TASK-073 ─► TASK-074
                      └─► TASK-075

PHASE 5 (ZNS)
Sprint 6 ─► TASK-077 ─┬─► TASK-078
                      └─► TASK-079
```

---

## ✅ Completed Tasks Log

| Date | Task | Notes |
|------|------|-------|
| 2026-02-04 | TASK-070 | Employee ServiceType Limits UI (Tab-Based) |
