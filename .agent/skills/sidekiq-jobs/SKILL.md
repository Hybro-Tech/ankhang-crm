---
name: sidekiq-jobs
description: Sidekiq background job patterns for Rails. Async processing, retries, scheduling, best practices.
allowed-tools: Read, Write, Edit, Glob, Grep
---

# Sidekiq Background Jobs

> **Reliable background processing.** Redis-backed, fast, battle-tested.
> Notifications, emails, heavy processing.

---

## 🎯 When to Use Background Jobs

| Use Sidekiq | Keep Synchronous |
|-------------|------------------|
| Email sending | Simple DB updates |
| Push notifications | Fast validations |
| External API calls | Redirects |
| Heavy computation | User-facing responses |
| Scheduled tasks | Real-time requirements |

---

## 🔧 Setup

```ruby
# Gemfile
gem 'sidekiq'
gem 'sidekiq-cron'  # For scheduled jobs

# config/application.rb
config.active_job.queue_adapter = :sidekiq

# config/initializers/sidekiq.rb
Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/1') }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/1') }
end
```

### Procfile

```
web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -C config/sidekiq.yml
```

### sidekiq.yml

```yaml
# config/sidekiq.yml
:concurrency: 10
:queues:
  - [critical, 3]
  - [default, 2]
  - [low, 1]
```

---

## 📝 Job Patterns

### Basic Job

```ruby
# app/jobs/send_notification_job.rb
class SendNotificationJob < ApplicationJob
  queue_as :default

  def perform(user_id, message)
    user = User.find(user_id)
    NotificationService.send(user, message)
  end
end

# Usage
SendNotificationJob.perform_later(user.id, "New contact available!")
```

### With Retries

```ruby
class ZaloMessageJob < ApplicationJob
  queue_as :critical
  retry_on ZaloAPI::RateLimitError, wait: :exponentially_longer, attempts: 5
  discard_on ZaloAPI::InvalidTokenError

  def perform(contact_id, template_id)
    contact = Contact.find(contact_id)
    ZaloService.send_template(contact.phone, template_id)
  end
end
```

### Sidekiq Worker (Direct API)

```ruby
# app/workers/broadcast_contact_created_worker.rb
class BroadcastContactCreatedWorker
  include Sidekiq::Worker

  sidekiq_options queue: :critical, retry: 3

  def perform(contact_id)
    contact = Contact.find(contact_id)

    # Broadcast to all sales users
    User.sales.find_each do |user|
      WebPushService.notify(user, {
        title: "Khách hàng mới!",
        body: contact.name,
        url: "/contacts/#{contact.id}"
      })
    end
  end
end

# Usage
BroadcastContactCreatedWorker.perform_async(contact.id)
```

---

## ⏰ Scheduled Jobs

```ruby
# config/initializers/sidekiq_cron.rb
Sidekiq::Cron::Job.load_from_hash({
  'daily_report' => {
    'cron' => '0 8 * * *',  # 8 AM daily
    'class' => 'DailyReportJob'
  },
  'cleanup_old_logs' => {
    'cron' => '0 2 * * 0',  # 2 AM every Sunday
    'class' => 'CleanupLogsJob'
  },
  'cskh_reminder' => {
    'cron' => '0 9 * * 1-5',  # 9 AM weekdays
    'class' => 'CskhReminderJob'
  }
})
```

---

## 🔔 AnKhangCRM Use Cases

### Contact Created Notification

```ruby
# app/models/contact.rb
class Contact < ApplicationRecord
  after_create_commit :notify_sales

  private

  def notify_sales
    BroadcastContactCreatedWorker.perform_async(id)
  end
end
```

### Zalo OA Message (CSKH)

```ruby
# app/jobs/send_zalo_message_job.rb
class SendZaloMessageJob < ApplicationJob
  queue_as :critical
  retry_on Faraday::TimeoutError, wait: 5.seconds, attempts: 3

  def perform(contact_id, template_id, params = {})
    contact = Contact.find(contact_id)

    result = ZaloOAService.send_zns(
      phone: contact.phone,
      template_id: template_id,
      data: params
    )

    ActivityLog.create!(
      trackable: contact,
      action: 'zalo_sent',
      metadata: { template_id: template_id, result: result }
    )
  end
end
```

### Email Notification

```ruby
# app/jobs/send_email_job.rb
class SendEmailJob < ApplicationJob
  queue_as :default

  def perform(user_id, email_type, options = {})
    user = User.find(user_id)

    case email_type.to_sym
    when :password_reset
      UserMailer.password_reset(user).deliver_now
    when :daily_summary
      UserMailer.daily_summary(user, options[:date]).deliver_now
    end
  end
end
```

---

## 📊 Queue Management

### Priority Queues

| Queue | Use For |
|-------|---------|
| `critical` | Real-time notifications, picks |
| `default` | General processing |
| `low` | Reports, cleanup |
| `mailers` | Email delivery |

### Bulk Processing

```ruby
# Process many items efficiently
class BulkNotifyJob < ApplicationJob
  def perform(user_ids)
    User.where(id: user_ids).find_each(batch_size: 100) do |user|
      # Process each user
    end
  end
end
```

---

## 🛡️ Error Handling

```ruby
class ReliableJob < ApplicationJob
  # Retry with exponential backoff
  retry_on StandardError, wait: :exponentially_longer, attempts: 5

  # Don't retry for specific errors
  discard_on ActiveRecord::RecordNotFound

  # Custom error handling
  rescue_from(CustomError) do |exception|
    # Log and notify admin
    Rails.logger.error("Job failed: #{exception.message}")
    AdminNotifier.job_failed(self.class.name, exception)
  end

  def perform(...)
    # job logic
  end
end
```

---

## 🔍 Monitoring

### Web UI

```ruby
# config/routes.rb
require 'sidekiq/web'
require 'sidekiq/cron/web'

authenticate :user, ->(u) { u.has_role?('Super Admin') } do
  mount Sidekiq::Web => '/sidekiq'
end
```

### Dead Set Handling

```ruby
# Check for failed jobs
ds = Sidekiq::DeadSet.new
ds.each do |job|
  # Retry or log
end
```

---

## ❌ Anti-Patterns

| Don't | Do Instead |
|-------|------------|
| Pass ActiveRecord objects | Pass IDs, reload in job |
| Long-running single job | Break into smaller jobs |
| Ignore retry limits | Set appropriate attempts |
| Skip error handling | Catch and log failures |
| Queue everything | Only async what's needed |

---

## ✅ Checklist

- [ ] Redis connection configured?
- [ ] Sidekiq process in Procfile?
- [ ] Queue priorities set?
- [ ] Retry strategies defined?
- [ ] Web UI mounted (admin only)?
- [ ] Error notifications set up?
