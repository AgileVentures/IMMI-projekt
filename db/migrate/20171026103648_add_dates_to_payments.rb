class AddDatesToPayments < ActiveRecord::Migration[5.1]
  def change

    reversible do |direction|
      direction.up do
        add_column :payments, :start_date, :date
        add_column :payments, :expire_date, :date
        add_column :payments, :notes, :text

        User.all.each do |user|
          next unless user.member?

          Payment.create(user: user,
                         payment_type: Payment::PAYMENT_TYPE_MEMBER,
                         status: Payment.order_to_payment_status('successful'),
                         hips_id: 'none',
                         start_date: Date.new(2017, 1, 1),
                         expire_date: Date.new(2017, 12, 31))
        end
      end

      direction.down do
        remove_columns :payments, :start_date, :expire_date, :notes
      end
    end
  end
end
