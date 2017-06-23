class AddEndLabelIdToTest < ActiveRecord::Migration
  def change
    add_column :tests, :end_label_id, :integer
  end
end
