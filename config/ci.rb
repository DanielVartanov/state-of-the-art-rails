# Run using bin/ci

CI.run do
  step 'Setup', 'bin/setup --skip-server'

  step 'Style: Ruby', 'bin/rubocop'

  step 'Security: Gem audit', 'bin/bundler-audit'
  step 'Security: Importmap vulnerability audit', 'bin/importmap audit'
  step 'Security: Brakeman code analysis', 'bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error'
  step 'Database: Schema consistency', 'bundle exec database_consistency'
  step 'Tests: Seeds', 'env RAILS_ENV=test bin/rails db:seed:replant'
  step 'Tests: Rails', 'just test'
  step 'Lint', 'just lint'
end
