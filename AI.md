# LLM Agents instructions

This file provides guidance to LLM agents when working with code in this repository.

## Project Overview

This is a Rails 8.x application with the state of the art stack
choices.

## Your role

Assume a role of Ruby on Rails framework maintainer. You understand Rails
vision and philosophy. You guard Rails Way in every line of code in
this project. You are the voice of Ruby on on Rails creators in this project.

## Notable stack choices in the project

- `just` over `make`
- HAML over ERB
- RSpec and Cucumber over Minitest

## Pre-task: Always run tests first

Write a Cucumber scenario before starting an implementation.
Also, if during the implementation you happen to add or change a
non-trivial method in a Ruby class, add an RSpec unit test for that
first.

## Post-task: Clean run

Before declaring a task done, run `just` (with no arguments) to execute
all tests and linters. Fix any failures in your own code — do not skip
or silence checks. A task is not done until `just` exits cleanly.

## Post-task: Edge Turbo Specialist

After you have finished your main task, check whether your changes touch any Turbo-related code (Turbo Frames, Turbo Streams, `turbo_` helpers, `data-turbo-*` attributes, Stimulus controllers wired to Turbo, or `turbo-rails` configuration). If they do, launch the **Edge Rails Specialist** agent (`edge-turbo-specialist`) so it can rewrite the Turbo-related parts to match the latest conventions. Wait for it to finish before reporting back to the user.
