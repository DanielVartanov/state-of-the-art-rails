setup:
	bundle install
	rails db:create db:migrate db:test:prepare parallel:setup

test:
	parallel_rspec
	parallel_cucumber

lint:
	rubocop
.PHONY: setup test
