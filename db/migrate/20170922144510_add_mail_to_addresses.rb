class AddMailToAddresses < ActiveRecord::Migration[5.1]
  def change
    add_column :addresses, :mail, :boolean, default: false
  end
end
