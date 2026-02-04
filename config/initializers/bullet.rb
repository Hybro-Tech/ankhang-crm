# frozen_string_literal: true

# TASK-PERF: Bullet for N+1 detection in development
# Currently DISABLED - will enable after fixing N+1 issues
# To re-enable: set Bullet.enable = true
Bullet.enable = false
Bullet.alert = false
Bullet.bullet_logger = false
Bullet.console = false
Bullet.rails_logger = false
Bullet.add_footer = false

# Optional: Raise errors on N+1 (useful for strict development)
# Bullet.raise = true
