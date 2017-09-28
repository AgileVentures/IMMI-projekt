class AddMailToAddresses < ActiveRecord::Migration[5.1]
  def change
    reversible do |direction|

      direction.up do
        # Only one address per company in DB
        add_column :addresses, :mail, :boolean, default: true
        change_column_default :addresses, :mail, false
      end

      direction.down do
        remove_column :addresses, :mail
      end

    end
  end
end
