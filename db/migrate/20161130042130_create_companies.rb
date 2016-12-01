class CreateCompanies < ActiveRecord::Migration[5.0]
  def change
    create_table :companies do |t|
      
      t.string :name
      t.string :company_number
      t.string :phone_number
      t.string :email
      t.string :street
      t.string :post_code
      t.string :city
      t.string :region
      t.string :website

      t.timestamps
    end
  end
end
