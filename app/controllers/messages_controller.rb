class MessagesController < ApplicationController
  def index
    @messages = Message.all.includes(:user)
  end

  def create
    @message = Message.create! params.require(:message).permit(:user_id, :content)
  end
end
