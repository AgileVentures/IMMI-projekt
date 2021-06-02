class CreateArchivedMemberships < ActiveRecord::Migration[5.2]
  def change
    create_table :archived_memberships do |t|
      t.string :member_number
      t.date :first_day, null: false
      t.date :last_day, null: false
      t.text :notes
      t.text :belonged_to_first_name, null: false, comment: 'The first name of the user this belonged to'
      t.text :belonged_to_last_name, null: false, comment: 'The last name of the user this belonged to'
      t.text :belonged_to_email, null: false, comment: 'The email for the user this belonged to'

      t.timestamps
    end
    add_index :archived_memberships, :belonged_to_last_name
    add_index :archived_memberships, :first_day
    add_index :archived_memberships, :last_day
  end
end
