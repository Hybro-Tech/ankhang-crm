---
description: Test generation and test running command using RSpec.
---

# /test - RSpec Test Generation and Execution

$ARGUMENTS

---

## Purpose

This command generates RSpec tests, runs existing specs, or checks test coverage for the Rails application.

---

## Sub-commands

```
/test                - Run all specs (bundle exec rspec)
/test [file]         - Generate/Run specs for specific file or model
/test coverage       - Show coverage report (SimpleCov)
/test failures       - Run only failing tests (--only-failures)
```

---

## Behavior

### Generate Tests

When asked to test a file or feature:

1. **Analyze the code**
   - Identify Model/Controller/Service responsibilities
   - Find edge cases and validations
   - Detect ActiveRecord associations

2. **Generate RSpec cases**
   - **Models**: Validations, associations, scopes, methods
   - **Controllers**: Requests, status codes, params, templating
   - **Services**: Business logic, happy path, error handling
   - **System**: User flows (Capybara)

3. **Write tests**
   - Use `FactoryBot` for data setup
   - Use `webmock` or `VCR` for external APIs
   - Follow strict RSpec describe/context/it hierarchy

---

## Output Format

### For Test Generation

```markdown
## 🧪 RSpec: [Target]

### Test Plan
| Context | Example | Type |
|---------|---------|------|
| validation | requires email presence | Model |
| #calculate | returns total with tax | Service |
| GET /index | shows list of items | Request |

### Generated Spec
`spec/models/[file]_spec.rb`

[Code block with Ruby code]

---

Run with: `bundle exec rspec spec/models/[file]_spec.rb`
```

### For Test Execution

```
🧪 Running specs...

Randomized with seed 12345

Consumer
  validations
    ✓ requires a name (0.02s)
    ✓ requires a valid email (0.01s)
  #total_orders
    ✓ returns sum of order amounts (0.05s)

Finished in 0.12345 seconds (files took 1.5 seconds to load)
3 examples, 0 failures
```

---

## Examples

```
/test app/models/user.rb
/test user registration flow
/test coverage
/test fix failed specs
```

---

## Test Patterns

### Model Spec Structure

```ruby
require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:orders) }
  end

  describe '#full_name' do
    let(:user) { build(:user, first_name: 'John', last_name: 'Doe') }

    it 'returns the concatenated name' do
      expect(user.full_name).to eq 'John Doe'
    end
  end
end
```

### Service Spec Structure

```ruby
require 'rails_helper'

RSpec.describe CalculateTaxService do
  subject(:service) { described_class.new(amount) }

  describe '#call' do
    context 'when amount is positive' do
      let(:amount) { 100 }

      it 'returns tax amount' do
        expect(service.call).to eq 10
      end
    end

    context 'when amount is negative' do
      let(:amount) { -50 }

      it 'raises error' do
        expect { service.call }.to raise_error(ArgumentError)
      end
    end
  end
end
```

---

## Key Principles

- **Use FactoryBot** instead of fixtures
- **One expectation per example**
- **Use `let` and `subject`** for lazy evaluation
- **Mock external services** (never hit real APIs in tests)
- **Test behavior, not implementation**
