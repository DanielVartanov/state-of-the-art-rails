class MessagesController < ApplicationController
  def index
    @messages = Message.all
  end

  def new
    @message = Message.new
  end

  def create
    @message = Message.new params.require(:message).permit(:user_id, :content)

    if @message.save
      redirect_to :messages
    else
      render :new
    end
  end
end
