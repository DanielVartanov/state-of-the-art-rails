class MessagesController < ApplicationController
  def index
    @message = Message.new
    @messages = Message.all.includes(:user)
  end

  def create
    message = Message.new params.require(:message).permit(:user_id, :content)

    if message.save
      @message = Message.new # Render a fresh empty form
    else
      @message = message
    end
  end
end
