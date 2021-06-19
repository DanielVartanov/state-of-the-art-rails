class User < ApplicationRecord
  has_many :messages

  def self.most_talkative
    User
      .left_outer_joins(:messages)
      .group(:id)
      .order('count(messages.id) desc')
      .first
  end
end
