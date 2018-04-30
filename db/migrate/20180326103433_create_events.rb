class CreateEvents < ActiveRecord::Migration[5.1]
  def change
    create_table :events do |t|
      t.decimal :fee, precision: 8, scale: 2
      t.date :start_date, index: true
      t.text :description
      t.string :dinkurs_id
      t.string :name
      t.string :sign_up_url
      t.string :place
      t.float :latitude
      t.float :longitude
      t.belongs_to :company, foreign_key: true

      t.timestamps
    end

    add_index :events, [:latitude, :longitude]
  end
end
