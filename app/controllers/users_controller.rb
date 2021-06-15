class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def create
    User.create! params.require(:user).permit(:name)
    redirect_to :users
  end
end
