class AddKlarnaIdToPayment < ActiveRecord::Migration[5.2]
  def change
    add_column :payments, :klarna_id, :string, default: nil
  end
end
