class AddInputLabelsToToTest < ActiveRecord::Migration
  def change
    add_column :tests, :input_labels, :text
  end
end
