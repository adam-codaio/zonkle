class AddWorldToParameter < ActiveRecord::Migration
  def change
    add_column :parameters, :world_id, :integer
  end
end
