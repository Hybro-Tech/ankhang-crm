---
name: view-component
description: Guidelines for building reusable UI components in Rails using the ViewComponent library.
allowed-tools: Read, Write, Edit, Glob, Grep
---

# ViewComponent Patterns

> **Component-Driven UI for Rails.**
> Encapsulate logic, template, and style into a single reusable unit.

---

## 🎯 When to use ViewComponent?

| Use ViewComponent | Use Partial (`_foo.html.erb`) |
|-------------------|-------------------------------|
| Complex logic in view | Simple logic-less rendering |
| Highly reusable UI elements (Button, Modal, Card) | One-off page sections |
| Needs strict testing | Simple loop rendering |
| Has internal state/methods | Relies on local variables |

---

## 🏗️ Structure

```
app/
└── components/
    ├── application_component.rb  # Base class
    └── ui/
        ├── button_component.rb
        └── button_component.html.erb
```

---

## 📝 Implementation Pattern

### 1. Ruby Component (`button_component.rb`)

```ruby
# app/components/ui/button_component.rb
module Ui
  class ButtonComponent < ApplicationComponent
    # Define acceptable variants as constants for safety
    VARIANTS = {
      primary: "bg-blue-600 text-white hover:bg-blue-700",
      secondary: "bg-gray-100 text-gray-900 hover:bg-gray-200",
      danger: "bg-red-600 text-white hover:bg-red-700"
    }.freeze

    def initialize(variant: :primary, size: :md, href: nil)
      @variant = variant
      @size = size
      @href = href
      @classes = "inline-flex items-center rounded border px-4 py-2 font-medium focus:outline-none focus:ring-2 focus:ring-offset-2 #{VARIANTS[variant]}"
    end

    def call
      # Decide whether to render a link or a button
      if @href
        link_to content, @href, class: @classes
      else
        button_tag content, class: @classes
      end
    end
  end
end
```

### 2. Template (`button_component.html.erb`)

*If `call` method is complex, use a template file. If simple, keep `call` in Ruby.*

### 3. Usage in View

```erb
<%= render Ui::ButtonComponent.new(variant: :danger, href: "/delete") do %>
  Delete Account
<% end %>
```

---

## 🧪 Testing (RSpec)

Testing components is much faster than system tests.

```ruby
# spec/components/ui/button_component_spec.rb
require "rails_helper"

RSpec.describe Ui::ButtonComponent, type: :component do
  it "renders the primary variant by default" do
    render_inline(described_class.new) { "Click me" }

    expect(page).to have_css "button.bg-blue-600", text: "Click me"
  end

  it "renders as a link when href is provided" do
    render_inline(described_class.new(href: "/home")) { "Go Home" }

    expect(page).to have_link "Go Home", href: "/home"
  end
end
```

---

## 🎨 Best Practices

1. **Namespace**: Group components logically (e.g., `Ui::`, `Layout::`, `Form::`).
2. **Slots**: Use slots for complex content layout (e.g., `header`, `body`, `footer` in a Modal).
3. **Stimulus**: Attach Stimulus controllers directly to the component wrapper.

```ruby
def initialize(controller: nil)
  @controller = controller
end

# In HTML
# <div data-controller="<%= @controller %>">
```
