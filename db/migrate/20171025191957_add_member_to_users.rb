class AddMemberToUsers < ActiveRecord::Migration[5.1]
  def change
    reversible do |direction|

      direction.up do
        add_column :users, :member, :boolean, default: false
      end

      direction.down do
        remove_column :users, :member
      end
    end
  end
end
