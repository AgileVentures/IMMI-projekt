class AddDinkursCompanyIdToCompany < ActiveRecord::Migration[5.1]
  def change
    add_column :companies, :dinkurs_company_id, :string
  end
end
