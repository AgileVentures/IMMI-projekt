class CreatePayments < ActiveRecord::Migration[5.1]
  def change
    create_table :payments do |t|
      t.references :user, foreign_key: true
      t.references :company, foreign_key: true
      t.string :payment_type
      t.string :status
      t.string :hips_id

      t.timestamps
    end
  end
end
