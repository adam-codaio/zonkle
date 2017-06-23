class CreateParameters < ActiveRecord::Migration
  def change
    create_table :parameters do |t|
      t.string :param
      t.string :desc
      t.text :value

      t.timestamps
    end
  end
end
