class User < ApplicationRecord
  has_many :messages, dependent: :destroy

  validates :name, length: { minimum: 3 }

  def self.most_talkative
    User
      .left_outer_joins(:messages)
      .group(:id)
      .order(Message.arel_table[:id].count.desc)
      .first
  end
end
