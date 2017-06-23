class CreateLabels < ActiveRecord::Migration
  def change
    create_table :labels do |t|
      t.text :desc

      t.timestamps
    end
  end
end
