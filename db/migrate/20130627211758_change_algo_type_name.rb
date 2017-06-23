class ChangeAlgoTypeName < ActiveRecord::Migration
  def up
  	rename_column :algorithms, :type, :atype
  end

  def down
  end
end
