# frozen_string_literal: true

class Message < ApplicationRecord
  belongs_to :user

  validates :content, length: { minimum: 2 }

  after_create_commit -> { broadcast_append_to 'messages_stream', target: 'messages' }
end
