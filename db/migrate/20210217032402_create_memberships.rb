class CreateMemberships < ActiveRecord::Migration[5.2]
  def change
    create_table :memberships do |t|
      t.belongs_to :user, foreign_key: true

      t.string :member_number
      t.date :first_day, null: false
      t.date :last_day, null: false
      t.text :notes

      t.timestamps
    end
    add_index :memberships, :first_day
    add_index :memberships, :last_day
  end
end
