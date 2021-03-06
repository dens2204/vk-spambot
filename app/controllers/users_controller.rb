class UsersController < ApplicationController
  include UsersHelper

  before_filter :authenticate_user!, :except => [:new, :create]
  before_filter :check_user,         :only   => [:show, :edit, :update, :destroy]

  load_and_authorize_resource :user

  skip_authorization_check :only => [:new, :create]

  def index
    @title = 'All users'
    @users = User.paginate(:page => params[:page])
  end

  def show
    @title = @user.name
  end

  def new
    @user = User.new
    @title = 'Sign up'
  end

  def edit
    @title = 'Edit user'
  end

  def create
    @user = User.new(params[:user])

    if @user.save
      redirect_to @user, :flash => { :success => 'Welcome to the... dunno!' }
    else
      @title = 'Sign up'
      @user.password = nil
      @user.password_confirmation = nil
      render 'new'
    end
  end

  def update
    if @user.update_attributes(params[:user])
      redirect_to @user, :flash => { :success => 'Profile was successfully updated.' }
    else
      @title = 'Edit user'
      render 'edit'
    end
  end

  def destroy
    if @user.has_role?(:admin)
      flash = { :error => 'Administrator cannot be destroyed.' }
    else
      @user.stop_bots

      # To stop bots after (bots.count * 10) seconds if user destroyed in short period of time after 'run' request
      Thread.new do
        sleep @user.bots.count * 10
        @user.stop_bots
      end

      @user.destroy
      flash = { :success => 'User destroyed.' }
    end
    redirect_to :back, :flash => flash
  end

end
