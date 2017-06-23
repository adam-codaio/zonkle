class CreateTestResults < ActiveRecord::Migration
  def change
    create_table :test_results do |t|
      t.integer :test_id
      t.integer :labela_id
      t.integer :labelb_id
      t.integer :choice_id

      t.timestamps
    end
  end
end
