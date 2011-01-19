class CreateParticipations < ActiveRecord::Migration
  def self.up
    create_table :participations do |t|
      t.integer  :user_id
      t.integer  :room_id
      t.datetime :entered_at
      t.datetime :left_at
    end
  end

  def self.down
    drop_table :participations
  end
end
