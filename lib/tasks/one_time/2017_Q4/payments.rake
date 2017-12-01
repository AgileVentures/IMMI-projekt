# PREREQUISITE MIGRATIONS:
# 20171013141538_create_payments
# 20171026103648_add_dates_to_payments

# PREREQUISITE RAKE TASKS:
# None

namespace :shf do
  namespace :payments do

    desc "Create 2017 branding payments for companies"
    task branding_2017: :environment do

      # This task adds an initial H-Branding fee payment, for all appropriate
      # companies, for the year 2017 (jan 1 to dec 31).
      # This "bootstraps" these companies so that subsequent branding payments
      # can correctly extend branding license from prior payment expire_date.

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
                          start_date: Time.zone.local(2017, 1, 1),
                          expire_date: Time.zone.local(2017, 12, 31))

        end
        log.record('info', "Added payments for #{payments_added} companies.")
      end
    end


    desc "Create 2017 membership payments for members"
    task membership_2017: :environment do

      # This task adds an initial membership fee payment, for all appropriate
      # users, for the year 2017 (jan 1 to dec 31).
      # This "bootstraps" these members so that subsequent membership payments
      # can correctly extend membership period from prior payment expire_date.

      LOG_FILE = 'log/membership_payment_2017'

      ActivityLogger.open(LOG_FILE, 'SHF_TASK', 'Add 2017 membership payments') do |log|

        members = User.joins(:membership_applications)
                      .where("membership_applications.state = 'accepted'")
                      .distinct

        payments_added = 0

        log.record('info', "Checking payment for #{members.count} members.")

        members.each do |member|

          next if member.most_recent_membership_payment

          payments_added += 1

          Payment.create!(user: member,
                          payment_type: Payment::PAYMENT_TYPE_MEMBER,
                          status: Payment.order_to_payment_status('successful'),
                          hips_id: 'none',
                          start_date: Time.zone.local(2017, 1, 1),
                          expire_date: Time.zone.local(2017, 12, 31))

        end
        log.record('info', "Added payments for #{payments_added} members.")
      end
    end
  end
end
