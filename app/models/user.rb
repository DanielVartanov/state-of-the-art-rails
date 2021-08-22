# frozen_string_literal: true

class User < ApplicationRecord
  has_many :messages

  validates :name, length: { minimum: 3 }

  def self.most_talkative
    User
      .left_outer_joins(:messages)
      .group(:id)
      .order('count(messages.id) desc')
      .first
  end
end
