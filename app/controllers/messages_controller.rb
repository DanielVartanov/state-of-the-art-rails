class MessagesController < ApplicationController
  def index
    @messages = Message.includes(:author).all
    @message = Message.new
    @authors = Author.all
  end

  def edit
    @message = Message.find(params[:id])
  end

  def update
    @message = Message.find(params[:id])

    if @message.update(message_params)
      redirect_to messages_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    Message.find(params[:id]).destroy
    redirect_to messages_path, status: :see_other
  end

  def create
    @message = Message.new(message_params)

    if @message.save
      redirect_to messages_path
    else
      @messages = Message.includes(:author).all
      @authors = Author.all
      render :index, status: :unprocessable_entity
    end
  end

  private

  def message_params
    params.expect(message: [:content, :author_id])
  end
end
