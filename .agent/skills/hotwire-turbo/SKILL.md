---
name: hotwire-turbo
description: Hotwire (Turbo + Stimulus) patterns for Rails 7+. Server-rendered HTML, minimal JavaScript, real-time updates.
allowed-tools: Read, Write, Edit, Glob, Grep
---

# Hotwire & Turbo Patterns

> **HTML Over The Wire** - Build modern UIs without heavy JavaScript.
> Turbo Drive, Turbo Frames, Turbo Streams, Stimulus.

---

## 🎯 Core Philosophy

| Principle | Meaning |
|-----------|---------|
| **HTML First** | Send HTML from server, not JSON |
| **Minimal JS** | Enhance HTML, don't build from scratch |
| **Progressive Enhancement** | Start simple, add interactivity as needed |
| **Server-Side State** | Keep state on server, not client |

---

## 🚀 Turbo Components

### Turbo Drive
- Intercepts navigation, updates `<body>` only
- SPA-like experience without custom JS
- **Default behavior** - no code needed

### Turbo Frames
- Decompose pages into independent sections
- Lazy load content
- Scoped updates

### Turbo Streams
- Real-time DOM manipulation
- WebSocket broadcasts
- Multiple targeted updates

---

## 📦 Turbo Frames Patterns

### Basic Frame

```erb
<%# app/views/contacts/index.html.erb %>
<turbo-frame id="contacts_list">
  <%= render @contacts %>
</turbo-frame>

<%# Links inside frame stay in frame %>
<%= link_to "New Contact", new_contact_path %>
```

### Lazy Loading

```erb
<%# Load content when visible %>
<turbo-frame id="recent_activities" src="<%= activities_path %>" loading="lazy">
  <p>Loading...</p>
</turbo-frame>
```

### Breakout Navigation

```erb
<%# Navigate full page from within frame %>
<%= link_to "View Details", contact_path(@contact), data: { turbo_frame: "_top" } %>
```

### Frame Targeting

```erb
<%# Update different frame %>
<%= link_to "Edit", edit_contact_path(@contact), data: { turbo_frame: "contact_form" } %>

<turbo-frame id="contact_form"></turbo-frame>
```

---

## 📡 Turbo Streams Patterns

### From Controller Response

```ruby
# app/controllers/contacts_controller.rb
def create
  @contact = Contact.new(contact_params)
  if @contact.save
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to contacts_path }
    end
  else
    render :new, status: :unprocessable_entity
  end
end
```

```erb
<%# app/views/contacts/create.turbo_stream.erb %>
<%= turbo_stream.prepend "contacts_list", @contact %>
<%= turbo_stream.update "contact_count", Contact.count %>
<%= turbo_stream.remove "new_contact_form" %>
```

### Stream Actions

| Action | Purpose |
|--------|---------|
| `append` | Add to end of container |
| `prepend` | Add to start of container |
| `replace` | Replace entire element |
| `update` | Replace content only |
| `remove` | Delete element |
| `before` | Insert before element |
| `after` | Insert after element |

### Real-time Broadcasts (ActionCable)

```ruby
# app/models/contact.rb
class Contact < ApplicationRecord
  after_create_commit { broadcast_prepend_to "contacts" }
  after_update_commit { broadcast_replace_to "contacts" }
  after_destroy_commit { broadcast_remove_to "contacts" }
end
```

```erb
<%# app/views/contacts/index.html.erb %>
<%= turbo_stream_from "contacts" %>

<div id="contacts">
  <%= render @contacts %>
</div>
```

### Broadcast from Sidekiq Job

```ruby
# app/jobs/notify_pick_job.rb
class NotifyPickJob < ApplicationJob
  def perform(contact_id)
    contact = Contact.find(contact_id)

    Turbo::StreamsChannel.broadcast_replace_to(
      "contacts",
      target: dom_id(contact),
      partial: "contacts/contact",
      locals: { contact: contact }
    )
  end
end
```

---

## ⚡ Stimulus Patterns

### Basic Controller

```javascript
// app/javascript/controllers/toggle_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content"]
  static values = { open: Boolean }

  toggle() {
    this.openValue = !this.openValue
  }

  openValueChanged() {
    this.contentTarget.hidden = !this.openValue
  }
}
```

```erb
<div data-controller="toggle" data-toggle-open-value="false">
  <button data-action="toggle#toggle">Toggle</button>
  <div data-toggle-target="content">Content here</div>
</div>
```

### Common Patterns

| Pattern | Use Case |
|---------|----------|
| **Targets** | Reference DOM elements |
| **Values** | Reactive data storage |
| **Outlets** | Cross-controller communication |
| **Actions** | Event handlers |

### Generic Reusable Controllers

```javascript
// app/javascript/controllers/clipboard_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["source"]

  copy() {
    navigator.clipboard.writeText(this.sourceTarget.value)
  }
}
```

---

## 🎨 Turbo 8 Morphing

```erb
<%# Enable morphing for smoother updates %>
<head>
  <meta name="turbo-refresh-method" content="morph">
</head>
```

```ruby
# Controller with morphing
def update
  @contact.update!(contact_params)
  redirect_to @contact, notice: "Updated!"
end
```

---

## 🔄 Pick Contact Real-time (AnKhangCRM)

```ruby
# app/services/contacts/pick_service.rb
def call
  ActiveRecord::Base.transaction do
    @contact.update!(status: :picked, assignee: @sales_user)

    # Hide pick button for all other users
    Turbo::StreamsChannel.broadcast_replace_to(
      "available_contacts",
      target: dom_id(@contact, :pick_button),
      html: "<span class='picked'>Đã được nhận</span>"
    )
  end
end
```

```erb
<%# app/views/contacts/_contact.html.erb %>
<div id="<%= dom_id(contact) %>">
  <%= contact.name %>

  <span id="<%= dom_id(contact, :pick_button) %>">
    <% if contact.new? && current_user.can_pick? %>
      <%= button_to "Nhận", contact_pick_path(contact),
        method: :post,
        data: { turbo_confirm: "Xác nhận nhận khách?" } %>
    <% elsif contact.picked? %>
      <span class="picked">Đã được nhận bởi <%= contact.assignee.name %></span>
    <% end %>
  </span>
</div>
```

---

## ❌ Anti-Patterns

| Don't | Do Instead |
|-------|------------|
| Complex client-side state | Keep state on server |
| Heavy JS frameworks with Turbo | Use Stimulus for enhancements |
| Nested Turbo Frames (deep) | Keep frames shallow |
| Skip `turbo_stream` format | Always provide fallback HTML |
| Forget frame IDs | Use `dom_id` helper |

---

## ✅ Decision Tree

```
Need UI update?
├── Full page reload OK? → Standard link
├── Section only? → Turbo Frame
├── Multiple sections? → Turbo Stream (response)
├── Real-time/WebSocket? → Turbo Stream (broadcast)
└── Client interaction only? → Stimulus
```
