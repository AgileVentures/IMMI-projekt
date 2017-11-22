namespace :payments do
  desc "Create 2017 branding payments for companies"
  task branding_2017: :environment do

    LOG_FILE = 'log/companies_branding_payment_2017'

    ActivityLogger.open(LOG_FILE, 'SHF_TASK', 'Add 2017 branding payments') do |log|

      companies = Company.joins(:membership_applications)
                         .where("membership_applications.state = 'accepted'")
                         .distinct

      user = User.where(admin: true).first

      payments_added = 0

      log.record('info', "Checking payment for #{companies.count} companies.")

      companies.each do |company|

        next if company.most_recent_branding_payment

        payments_added += 1

        Payment.create!(user: user,
                        company: company,
                        payment_type: Payment::PAYMENT_TYPE_BRANDING,
                        status: Payment.order_to_payment_status('successful'),
                        hips_id: 'none',
                        start_date: Date.new(2017, 1, 1),
                        expire_date: Date.new(2017, 12, 31))

      end
      log.record('info', "Added payments for #{payments_added} companies.")
    end
  end
end
