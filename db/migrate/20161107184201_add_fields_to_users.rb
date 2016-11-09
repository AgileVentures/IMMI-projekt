class AddFieldsToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :first_name,   :string,  null: false, default: ""
    add_column :users, :last_name,    :string,  null: false, default: ""
    add_column :users, :street,       :string,  null: false, default: ""
    add_column :users, :postal_code,  :integer, null: false, default: ""
    add_column :users, :city,         :string,  null: false, default: ""
    add_column :users, :phone,        :integer
    add_column :users, :business_number, :integer
  end
end
