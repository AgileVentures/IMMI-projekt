class ChangeBusinessNumberInUsers < ActiveRecord::Migration[5.0]
  def change
    change_column :users, :business_number, :integer, limit: 8
  end
end
