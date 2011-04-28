class Room < ActiveRecord::Base

  has_many :participations
  has_many :users, :through => :participations


  def to_s
    name
  end

end
