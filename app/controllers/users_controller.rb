class UsersController < ApplicationController
  include UsersHelper

  before_filter :check_user,   :only => [:show, :edit, :update, :destroy]
  before_filter :authenticate, :only => [:index, :show, :edit, :update, :destroy]
  before_filter :correct_user, :only => [:edit, :update]
  before_filter :admin_user,   :only => :destroy

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
      sign_in @user unless current_user && current_user.admin?
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
    if @user.admin?
      _flash = { :error => 'Administrator cannot be destroyed.' }
    else
      @user.destroy
      _flash = { :success => 'User destroyed.' }
    end
    redirect_to :back, :flash => _flash
  end

end
