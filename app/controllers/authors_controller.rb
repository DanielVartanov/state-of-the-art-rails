class AuthorsController < ApplicationController
  def index
    @authors = Author.all
    @author = Author.new
  end

  def create
    @author = Author.new(author_params)

    if @author.save
      redirect_to authors_path
    else
      @authors = Author.all
      render :index, status: :unprocessable_entity
    end
  end

  private

  def author_params
    params.expect(author: [:name])
  end
end
