class MoveVisibilityToAddresses < ActiveRecord::Migration[5.1]
  def change
    reversible do |direction|

      direction.up do
        add_column :addresses, :visibility, :string, default: 'street_address'

        Company.all.each do |company|
          # At the time of this migration we have only allowed one address
          address = company.addresses.first
          if address
            address.visibility = company.address_visibility
            address.save!
          end
        end

        remove_column :companies, :address_visibility
      end

      direction.down do
        add_column :companies, :address_visibility, :string, default: 'street_address'

        Company.all.each do |company|
          address = company.addresses.first
          if address
            company.address_visibility = address.visibility
            company.save!
          end
        end

        remove_column :addresses, :visibility
      end
    end
  end
end
