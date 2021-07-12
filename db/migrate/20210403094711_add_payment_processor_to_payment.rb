class AddPaymentProcessorToPayment < ActiveRecord::Migration[5.2]
  def change
    add_column :payments, :payment_processor, :string, default: nil
  end
end
