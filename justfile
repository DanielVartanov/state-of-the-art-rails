# Run all checks (tests + linting + security/consistency)
default: test lint checks

# Install deps, create DB, migrate, prepare test DB
setup:
    bundle install
    bin/rails db:create db:migrate db:test:prepare

# Run all tests
test: rspec cucumber

# Run linters
lint: rubocop haml-lint

# Run security and consistency checks
checks: brakeman bundler-audit importmap-audit database-consistency

# RSpec unit and integration tests
rspec:
    bundle exec rspec

# Cucumber acceptance tests
cucumber:
    bundle exec cucumber

# Ruby style checks
rubocop:
    bin/rubocop

# HAML template linting
haml-lint:
    bundle exec haml-lint

# Security: static analysis
brakeman:
    bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error

# Security: gem vulnerability audit
bundler-audit:
    bin/bundler-audit

# Security: importmap vulnerability audit
importmap-audit:
    bin/importmap audit

# Database schema consistency
database-consistency:
    bundle exec database_consistency
