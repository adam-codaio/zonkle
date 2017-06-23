class AddSubjectDataToTest < ActiveRecord::Migration
  def change
    add_column :tests, :subject_data, :string
  end
end
