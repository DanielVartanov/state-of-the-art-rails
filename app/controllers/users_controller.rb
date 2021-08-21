class UsersController < ApplicationController
  before_action :find_users

  def index
    @user = User.new
  end

  def create
    @user = User.new params.require(:user).permit(:name)

    if @user.save
      redirect_to :users, notice: "New user #{@user.name} is now a part of the system"
    else
      flash.now.alert = 'There was a problem adding a new user'
      render :index, status: :unprocessable_entity
    end
  end

  private

  def find_users
    @users = User.all
  end
end
