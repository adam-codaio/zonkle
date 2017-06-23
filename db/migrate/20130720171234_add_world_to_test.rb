class AddWorldToTest < ActiveRecord::Migration
  def change
    add_column :tests, :world_id, :integer
  end
end
