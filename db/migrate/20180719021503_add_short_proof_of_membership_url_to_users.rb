class AddShortProofOfMembershipUrlToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :short_proof_of_membership_url, :string
  end
end
