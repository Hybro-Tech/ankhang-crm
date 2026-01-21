# ============================================
# AnKhangCRM Dockerfile (Development Only)
# ============================================
# Optimized for local development
# - Multi-stage for Node.js binaries
# - Non-root user for security
# - Health check included
# ============================================

# Stage 1: Node.js (copy binaries to avoid apt network issues)
FROM node:20-slim AS node

# ============================================
# Stage 2: Development
# ============================================
FROM ruby:3.3-slim AS development

# Copy Node.js and npm from node stage
COPY --from=node /usr/local/bin/node /usr/local/bin/
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm

# Install system dependencies
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    build-essential \
    default-libmysqlclient-dev \
    git \
    libvips \
    libyaml-dev \
    pkg-config \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user for security
RUN groupadd --gid 1000 rails && \
    useradd --uid 1000 --gid 1000 --create-home --shell /bin/bash rails

WORKDIR /app

ENV RAILS_ENV=development
ENV BUNDLE_PATH=/usr/local/bundle

# Install gems (as root for bundle install to shared volume)
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy application code
COPY --chown=rails:rails . .

# Switch to non-root user
USER rails

EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:3000/up || exit 1

CMD ["rails", "server", "-b", "0.0.0.0"]
