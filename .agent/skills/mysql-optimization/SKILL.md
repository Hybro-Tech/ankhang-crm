---
name: mysql-optimization
description: MySQL database optimization patterns. Indexing, query tuning, Rails integration.
allowed-tools: Read, Write, Edit, Glob, Grep
---

# MySQL Optimization

> **MySQL 8+ best practices for Rails.**
> Indexing, query optimization, performance.

---

## 🎯 Core Principles

| Principle | Meaning |
|-----------|---------|
| **Index First** | Add indexes before optimizing queries |
| **Explain Always** | Use EXPLAIN before complex queries |
| **Measure, Don't Guess** | Profile before optimizing |
| **Read > Write** | Optimize for read-heavy workloads |

---

## 📊 Essential Indexes

### Foreign Keys

```ruby
# db/migrate/xxx_add_indexes.rb
class AddIndexes < ActiveRecord::Migration[7.1]
  def change
    # Foreign keys (always index)
    add_index :contacts, :assignee_id
    add_index :contacts, :team_id
    add_index :deals, :contact_id
    add_index :activity_logs, [:trackable_type, :trackable_id]

    # Frequently queried columns
    add_index :contacts, :status
    add_index :contacts, :created_at
    add_index :deals, :payment_status

    # Composite indexes (order matters!)
    add_index :contacts, [:status, :created_at]
    add_index :contacts, [:team_id, :status]
  end
end
```

### Unique Indexes

```ruby
add_index :users, :email, unique: true
add_index :contacts, :phone, unique: true
add_index :permissions, [:subject, :action], unique: true
```

---

## 🔍 Query Optimization

### Use EXPLAIN

```ruby
# In Rails console
Contact.where(status: :new).explain
# Check for "Using filesort" or "Using temporary" (bad)
# Look for "Using index" (good)
```

### Avoid N+1 Queries

```ruby
# Bad
@contacts = Contact.all
@contacts.each { |c| c.assignee.name }  # N+1!

# Good
@contacts = Contact.includes(:assignee)
@contacts.each { |c| c.assignee.name }  # 2 queries

# With multiple associations
@deals = Deal.includes(:contact, :products, :assignee)
```

### Bullet Gem Setup

```ruby
# Gemfile
group :development do
  gem 'bullet'
end

# config/environments/development.rb
config.after_initialize do
  Bullet.enable = true
  Bullet.alert = true
  Bullet.bullet_logger = true
  Bullet.console = true
  Bullet.rails_logger = true
end
```

---

## 📈 Common Patterns

### Pagination

```ruby
# Use kaminari or pagy
@contacts = Contact.page(params[:page]).per(25)

# With complex query
Contact.where(status: :new)
       .includes(:team)
       .order(created_at: :desc)
       .page(params[:page])
```

### Counter Cache

```ruby
# Migration
add_column :teams, :contacts_count, :integer, default: 0

# Model
class Contact < ApplicationRecord
  belongs_to :team, counter_cache: true
end

# Usage (no query needed)
team.contacts_count
```

### Pluck vs Select

```ruby
# When you need just IDs
contact_ids = Contact.where(status: :new).pluck(:id)

# When you need specific columns (returns array)
Contact.where(status: :new).pluck(:id, :name, :phone)

# When you need objects with limited columns
Contact.select(:id, :name, :phone).where(status: :new)
```

---

## 🏎️ Performance Tricks

### Batch Processing

```ruby
# Process large datasets
Contact.where(status: :failed).find_each(batch_size: 500) do |contact|
  # Process in batches of 500
end

# With in_batches for bulk operations
Contact.where(status: :old).in_batches(of: 1000) do |batch|
  batch.update_all(archived: true)
end
```

### Raw SQL When Needed

```ruby
# For complex aggregations
ActiveRecord::Base.connection.execute(<<~SQL)
  SELECT team_id, COUNT(*) as contact_count, SUM(deals.amount) as total_value
  FROM contacts
  LEFT JOIN deals ON deals.contact_id = contacts.id
  WHERE contacts.status = 'closed'
  GROUP BY team_id
SQL
```

### Upsert

```ruby
# MySQL 8+ upsert
Contact.upsert_all(
  [{ phone: '0901234567', name: 'John', source: 'ladi_zalo' }],
  unique_by: :phone
)
```

---

## 🔒 MySQL-Specific Features

### Full-Text Search

```ruby
# Migration
add_index :contacts, [:name, :phone], type: :fulltext, name: 'contacts_fulltext'

# Query
Contact.where("MATCH(name, phone) AGAINST(? IN BOOLEAN MODE)", params[:q])
```

### JSON Columns

```ruby
# Migration
add_column :activity_logs, :metadata, :json

# Query
ActivityLog.where("JSON_EXTRACT(metadata, '$.action') = ?", 'pick')
```

---

## 📊 Monitoring

### Slow Query Log

```sql
-- my.cnf
[mysqld]
slow_query_log = 1
slow_query_log_file = /var/log/mysql/slow.log
long_query_time = 1
```

### Rails Logging

```ruby
# config/environments/production.rb
config.active_record.verbose_query_logs = true

# Log queries over 500ms
ActiveSupport::Notifications.subscribe('sql.active_record') do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  if event.duration > 500
    Rails.logger.warn "SLOW QUERY (#{event.duration.round}ms): #{event.payload[:sql]}"
  end
end
```

---

## ❌ Anti-Patterns

| Don't | Do Instead |
|-------|------------|
| `SELECT *` in code | Select specific columns |
| Missing foreign key indexes | Always index FKs |
| Complex queries in views | Use scopes, cache |
| Large `IN` clauses | Batch with `find_each` |
| String concatenation in queries | Use parameterized queries |

---

## ✅ Checklist

- [ ] All foreign keys indexed?
- [ ] Bullet gem enabled in dev?
- [ ] Counter caches for counts?
- [ ] Pagination on list views?
- [ ] EXPLAIN checked for complex queries?
- [ ] Slow query log enabled?
