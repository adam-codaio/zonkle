class AddSeedToLabels < ActiveRecord::Migration
  def change
    add_column :labels, :seed, :boolean
  end
end
