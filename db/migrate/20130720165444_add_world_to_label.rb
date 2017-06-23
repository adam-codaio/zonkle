class AddWorldToLabel < ActiveRecord::Migration
  def change
    add_column :labels, :world_id, :integer
  end
end
