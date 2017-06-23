class AddStartToWorld < ActiveRecord::Migration
  def change
    add_column :worlds, :start, :datetime
  end
end
