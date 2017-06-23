class CreateAlgorithms < ActiveRecord::Migration
  def change
    create_table :algorithms do |t|
      t.integer :type
      t.string :name
      t.string :desc
      t.text :algo

      t.timestamps
    end
  end
end
