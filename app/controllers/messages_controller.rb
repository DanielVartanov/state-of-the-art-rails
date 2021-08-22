class MessagesController < ApplicationController
  def index
    @messages = Message.all.includes(:user)
  end

  def create
    @message = Message.create! params.require(:message).permit(:user_id, :content)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to :messages }
    end
  end
end
