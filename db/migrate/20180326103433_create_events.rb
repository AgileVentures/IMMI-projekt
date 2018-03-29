class CreateEvents < ActiveRecord::Migration[5.1]
  def change
    create_table :events do |t|
      t.decimal :fee, precision: 8, scale: 2
      t.date :start_date
      t.text :description
      t.string :dinkurs_id
      t.string :name
      t.string :sing_up_url
      t.belongs_to :company, foreign_key: true

      t.timestamps
    end
  end
end
