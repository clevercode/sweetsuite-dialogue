class RoomsController < ApplicationController

  before_filter :authenticate_user!

  def index
    @rooms = Room.all
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
