# AnKhangCRM

> Hệ thống CRM quản lý khách hàng cho doanh nghiệp

---

## 🚀 Tech Stack

| Component | Technology |
|-----------|------------|
| **Backend** | Ruby on Rails 8.0 |
| **Database** | MySQL 8.0 |
| **Cache** | Solid Cache (MySQL) |
| **Background Jobs** | Solid Queue (MySQL) |
| **Frontend** | Hotwire (Turbo + Stimulus) |
| **CSS** | Tailwind CSS |
| **Auth** | Devise |
| **Authorization** | CanCanCan |
| **Testing** | RSpec + FactoryBot |

---

## 📦 Development Setup

### Prerequisites
- Docker & Docker Compose

### Quick Start

```bash
# Clone repository
git clone <repo-url>
cd ankhang-crm

# Start all services
docker-compose up -d

# Install gems (first time only)
docker-compose run --rm app bundle install

# Create database
docker-compose exec app rails db:create db:migrate

# Visit http://localhost:3000
```

---

## 🧪 Testing

```bash
# Run RSpec tests
docker-compose exec app bundle exec rspec

# Run RuboCop linter
docker-compose exec app bundle exec rubocop
```

---

## 📁 Project Structure

```
ankhang-crm/
├── app/                 # Rails application
├── config/              # Configuration files
├── db/                  # Database migrations & seeds
├── docs/                # Documentation
│   └── planning/        # Sprint planning
├── spec/                # RSpec tests
├── Dockerfile           # Docker image
├── docker-compose.yml   # Docker Compose config
└── Gemfile              # Ruby dependencies
```

---

## 📄 License

Private - All rights reserved.
