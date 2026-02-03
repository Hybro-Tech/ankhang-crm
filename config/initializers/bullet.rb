# frozen_string_literal: true

# TASK-PERF: Enable Bullet for N+1 detection in development
# To view Bullet warnings, check:
# - Browser console
# - Rails log
# - Footer notification
Bullet.enable = true
Bullet.alert = true
Bullet.bullet_logger = true
Bullet.console = true
Bullet.rails_logger = true
Bullet.add_footer = true

# Optional: Raise errors on N+1 (useful for strict development)
# Bullet.raise = true
