class RoomsController < ApplicationController

  before_filter :authenticate_user!
  respond_to :html, :json

  def index
    @rooms = Room.all
    respond_with(@rooms)
  end

  def show
    @rooms = Room.all
    @room = Room.find(params[:id])
  end

  def new
    @room = Room.new
  end

  def create
    @room = Room.new(params[:room])
    if @room.save
      redirect_to @room
    else
      render :new
    end
  end




end
