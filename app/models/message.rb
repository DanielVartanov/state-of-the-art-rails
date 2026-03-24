class Message < ApplicationRecord
  belongs_to :user

  validates :content, length: { minimum: 2 }

  after_create_commit { broadcast_append_to "messages_stream" }
  after_update_commit { broadcast_replace_to "messages_stream" }
  after_destroy_commit { broadcast_remove_to "messages_stream" }

  def as_quote
    "\"#{content}\" by #{user.name}"
  end
end
