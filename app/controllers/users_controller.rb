class UsersController < ApplicationController
  def new
    @title = "Sign up"
  end

  def show
    @user = User.find(params[:id])
    @title = @user.name
  end

  # this supports the user signup page
  def new
    @user = User.new
    @title = "Sign up"
  end

  # deliver successful signup or failed one
  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
    else
      @title = "Sign up"
      render 'new'
    end
  end
end
