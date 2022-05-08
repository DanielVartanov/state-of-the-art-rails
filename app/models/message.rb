# frozen_string_literal: true

class Message < ApplicationRecord
  belongs_to :user

  validates :content, length: { minimum: 2 }

  broadcasts_to ->(_) { 'messages_stream' }

  def as_quote
    "\"#{content}\" by #{user.name}"
  end
end
