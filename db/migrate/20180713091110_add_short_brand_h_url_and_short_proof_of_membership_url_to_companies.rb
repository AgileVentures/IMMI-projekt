class AddShortBrandHUrlAndShortProofOfMembershipUrlToCompanies < ActiveRecord::Migration[5.1]
  def change
    add_column :companies, :short_h_brand_url, :string
    add_column :companies, :short_proof_of_membership_url, :string
  end
end
