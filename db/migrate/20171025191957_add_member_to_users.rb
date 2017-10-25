class AddMemberToUsers < ActiveRecord::Migration[5.1]
  def change
    reversible do |direction|

      direction.up do
        add_column :users, :member, :boolean, default: false

        User.all.each do |user|
          user.member = user.is_member?
          user.save
        end
      end

      direction.down do
        remove_column :users, :member
      end
    end
  end
end
