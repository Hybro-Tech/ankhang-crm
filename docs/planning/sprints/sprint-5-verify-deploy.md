# Sprint 5: Verification & Deployment (Week 10)

> **Duration**: Week 10 (24/03 - 31/03)
> **Focus**: Security, Production Deployment, UAT, Feedback Fixes
> **Total Tasks**: 5

---

## Epic: Optimization & Fixes

### TASK-042: Kiểm thử UAT & Sửa lỗi
| Field            | Value        |
| ---------------- | ------------ |
| **Epic**         | Optimization |
| **Story Points** | 5            |
| **Priority**     | 🔴 Critical   |
| **Assignee**     |              |
| **Status**       | ✅ Done       |

**User Story:**
> Là User, tôi muốn hệ thống chạy ổn định và được sửa các lỗi tôi đã báo cáo.

**Description:**
Giai đoạn dành riêng cho việc test cùng khách hàng (UAT) và sửa lỗi.

**Acceptance Criteria:**
- [x] List bugs from UAT
- [x] Fix critical/high priority bugs (0 bugs found)
- [x] UI/UX tuning based on feedback
- [x] Performance tuning (nếu cần)
- [x] Test coverage: 404 examples, 0 failures

---

## Epic: Deployment

### TASK-043: Kiểm tra Bảo mật
| Field            | Value      |
| ---------------- | ---------- |
| **Epic**         | Deployment |
| **Story Points** | 3          |
| **Priority**     | 🔴 Critical |
| **Assignee**     |            |
| **Status**       | ✅ Done     |

**User Story:**
> Là Developer, tôi muốn đảm bảo app secure trước khi deploy.

**Acceptance Criteria:**
- [x] Run Brakeman (Rails security scanner) - 0 warnings
- [x] Fix all critical/high issues - N/A (none found)
- [x] OWASP checklist review
- [x] Rack::Attack configured (rate limiting)
- [ ] SSL/TLS enforced (production config)
- [x] Secrets không trong code

**Test Cases:**
- [x] Brakeman 0 critical
- [x] Rate limiting works (Rack::Attack configured)
- [ ] Non-HTTPS redirect to HTTPS (production)

---

### TASK-044: Cài đặt Server Production
| Field            | Value      |
| ---------------- | ---------- |
| **Epic**         | Deployment |
| **Story Points** | 5          |
| **Priority**     | 🔴 Critical |
| **Assignee**     |            |
| **Status**       | Backlog    |

**User Story:**
> Là DevOps, tôi muốn deploy app lên production server.

**Acceptance Criteria:**
- [ ] Server provisioned (AWS/VPS)
- [ ] Docker Compose production config
- [ ] Nginx reverse proxy + SSL
- [ ] MySQL master setup
- [ ] Redis setup
- [ ] Sidekiq running
- [ ] Environment variables configured
- [ ] Domain configured

**Test Cases:**
- [ ] App accessible via HTTPS
- [ ] All services running
- [ ] Logs accessible

---

### TASK-045: Backup & Monitoring
| Field            | Value      |
| ---------------- | ---------- |
| **Epic**         | Deployment |
| **Story Points** | 3          |
| **Priority**     | 🔴 Critical |
| **Assignee**     |            |
| **Status**       | Backlog    |

**User Story:**
> Là DevOps, tôi muốn có backup tự động và monitoring.

**Acceptance Criteria:**
- [ ] Daily MySQL backup (automated)
- [ ] Backup to S3/offsite
- [ ] Error tracking (Sentry)
- [ ] Performance monitoring (Skylight/New Relic)
- [ ] Uptime monitoring
- [ ] RPO < 15 phút, RTO < 4 giờ (SRS requirement)

**Test Cases:**
- [ ] Backup runs daily
- [ ] Restore from backup works
- [ ] Sentry receives errors

---

### TASK-046: Tài liệu & Bàn giao
| Field            | Value      |
| ---------------- | ---------- |
| **Epic**         | Deployment |
| **Story Points** | 3          |
| **Priority**     | 🟢 Medium   |
| **Assignee**     |            |
| **Status**       | Backlog    |

**User Story:**
> Là Stakeholder, tôi muốn có tài liệu để vận hành hệ thống.

**Acceptance Criteria:**
- [ ] README updated
- [ ] Deployment guide
- [ ] User guide (cho end users)
- [ ] Admin guide
- [ ] API documentation (nếu có)

---

## 📊 Sprint 5 Summary

| Priority   | Count |
| ---------- | ----- |
| 🔴 Critical | 4     |
| 🟢 Medium   | 1     |

**Total Story Points:** ~19

**Dependencies:**
- All features completed (Sprint 4)
- User availability for UAT
