class CreateTests < ActiveRecord::Migration
  def change
    create_table :tests do |t|
      t.integer :explicit_label_id

      t.timestamps
    end
  end
end
