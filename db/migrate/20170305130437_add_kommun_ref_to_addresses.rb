class AddKommunRefToAddresses < ActiveRecord::Migration[5.0]
  def change
    add_reference :addresses, :kommun, foreign_key: true
    remove_column :addresses, :kommun, :string
  end
end
