class AddIpBrowserToTest < ActiveRecord::Migration
  def change
    add_column :tests, :ip, :string
    add_column :tests, :host, :string
    add_column :tests, :browser, :string
  end
end
