class AddShortHBrandUrlToCompanies < ActiveRecord::Migration[5.1]
  def change
    add_column :companies, :short_h_brand_url, :string
  end
end
