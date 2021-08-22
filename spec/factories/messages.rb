# frozen_string_literal: true

FactoryBot.define do
  factory :message do
    user
    content { Faker::Quote.famous_last_words }
  end
end
