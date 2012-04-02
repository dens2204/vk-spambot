require 'core/bot'
require 'bots/group'
require 'bots/discussion'
#require 'openwfe/util/scheduler'
#include OpenWFE

class BotsController < ApplicationController
  before_filter :admin_user, :except => [:index, :new, :create, :run, :stop]
  before_filter :admin_user_control, :only => [:run, :stop]

  # GET /bots
  # GET /bots.json
  def index
    begin
      @bots = current_user.admin? && params[:id] ? User.find(params[:id]).bots : current_user.bots
    rescue
        flash.now[:error] = "User not found."
        render "error"
    else
      @title = "Listing bots"

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @bots }
      end
    end
  end

  # GET /bots/1
  # GET /bots/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @bot }
    end
  end

  # GET /bots/new
  # GET /bots/new.json
  def new
    @bot = Bot.new
    @title = "New bot"

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @bot }
    end
  end

  # GET /bots/1/edit
  def edit
    @bot.password = ""
    @title = "Edit bot"
  end

  # POST /bots
  # POST /bots.json
  def create
    params[:bot][:user_id] = current_user.admin? ? params[:id] || current_user.id : current_user.id
    @bot = Bot.new(params[:bot])

    respond_to do |format|
      if @bot.save
        format.html { redirect_to @bot, notice: "Bot was successfully created." }
        format.json { render json: @bot, status: :created, location: @bot }
      else
        @title = "New bot"
        format.html { render action: "new" }
        format.json { render json: @bot.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /bots/1
  # PUT /bots/1.json
  def update
    respond_to do |format|
      if @bot.update_attributes(params[:bot])
        format.html { redirect_to @bot, notice: "Bot was successfully updated." }
        format.json { head :no_content }
      else
        @title = "Edit bot"
        format.html { render action: "edit" }
        format.json { render json: @bot.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bots/1
  # DELETE /bots/1.json
  def destroy
    @bot.destroy

    respond_to do |format|
      format.html { redirect_to :controller => 'bots', :action => 'index', :id => @bot.user_id }
      format.json { head :no_content }
    end
  end

  def run
    #test = %x[rake spam:group email=#{@bot.email} password=#{@bot.password}, page=#{@bot.page}, hash=#{@bot.page_hash}, message=#{@bot.message}, count=#{@bot.count} interval=#{@bot.interval}]
    user_bot = runBot(@bot)
    if user_bot.initLogin
    #  scheduler = Scheduler.new
    #  scheduler.start
    #  scheduler.schedule_every("5s") { bot_init.spam }
    #  scheduler.join
      user_bot.spam
      response = { 'state' => 'ok' }
    else
      response = { 'state' => 'login error' }
    end

    respond_to do |format|
      format.json { render :json => response }
    end
  end

  def stop
    #test = %x[rake spam:group email=#{@bot.email} password=#{@bot.password}, page=#{@bot.page}, hash=#{@bot.page_hash}, message=#{@bot.message}, count=#{@bot.count} interval=#{@bot.interval}]
    #user_bot = runBot(@bot)
    #if user_bot.initLogin
    #  user_bot.spam
      response = { 'state' => 'ok' }
    #else
    #  response = { 'state' => 'login error' }
    #end

    respond_to do |format|
      format.json { render :json => response }
    end
  end

  private

    def runBot(bot)
      if bot.bot_type == 'group'
        _bot = Bots::Group.new(bot.email, bot.password, bot.page, bot.page_hash, bot.message, bot.count)
      elsif bot.bot_type == 'discussion'
        _bot = Bots::Discussion.new(bot.email, bot.password, bot.page, bot.page_hash, bot.message, bot.count)
      else
        return false
      end

      return _bot
    end

    def admin_user
      @bot = current_user.admin? ? Bot.find(params[:id]) : current_user.bots.find(params[:id])
      rescue
        flash.now[:error] = "Access denied."
        render "error"
    end

    def admin_user_control
      @bot = current_user.admin? ? Bot.find(params[:id]) : current_user.bots.find(params[:id])
      rescue
        respond_to do |format|
          format.json { render :json => { 'state' => 'access denied' } }
        end
    end

end