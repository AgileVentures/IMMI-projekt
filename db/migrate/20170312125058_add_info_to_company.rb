class AddInfoToCompany < ActiveRecord::Migration[5.0]
  def change
    add_column :companies, :info, :text
  end
end
