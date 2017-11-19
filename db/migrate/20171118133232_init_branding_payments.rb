class InitBrandingPayments < ActiveRecord::Migration[5.1]
  def change

    reversible do |direction|
      direction.up do

        Company.joins(:membership_applications).each do |company|

          user = company.users.first
          next unless user

          Payment.create(company: company,
                         user: user,
                         payment_type: Payment::PAYMENT_TYPE_BRANDING,
                         status: Payment.order_to_payment_status('successful'),
                         hips_id: 'none',
                         start_date: Date.new(2017, 1, 1),
                         expire_date: Date.new(2017, 12, 31))
        end
      end

      direction.down do

        Company.joins(:payments).each do |company|
          company.payments.destroy_all
        end
      end
    end
  end
end
