#--------------------------
#
# @module DataCreationHelper
#
# @desc Responsibility:  Methods to help with complex data creation for specifications and tests
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com)  weedySeaDragon @ github)
# @date   1/3/18
#
# @file data_creation_helper.rb
#
#--------------------------


module DataCreationHelper


  SUCCESSFUL_PAYMENT = Payment::ORDER_PAYMENT_STATUS['successful']

  UPLOADS_PATH = File.join(FIXTURES_PATH, 'uploaded_files')
  UPLOAD_PNG_FILE = File.join(UPLOADS_PATH, 'image.png')

  NUM_APPS_IN_STATE = { new: 1, under_review: 2, waiting_for_applicant: 1,
                        ready_for_review: 2, accepted: 1, rejected: 2 }.freeze


  # create [num] SHF applications in the given state
  # return the list of SHF applications created
  def create_shf_apps_in_state(num, state, create_date: Time.current)
    shf_apps = []

    num.times do
      shf_apps << create(:shf_application, state: state, created_at: create_date,
                         updated_at: create_date)
    end

    shf_apps
  end


  # create applications in all states and set the created_at: and updated_at dates to create_date
  # default create_date = Time.zone.now
  def create_apps_in_states(create_date: Time.current)

    NUM_APPS_IN_STATE.each_pair do |state, number|
      create_shf_apps_in_state(number, state, create_date: create_date)
    end

  end


  # add an uploaded file to the SHF application
  def add_uploaded_file(shf_app)
    shf_app.uploaded_files << create(:uploaded_file, actual_file: File.open(UPLOAD_PNG_FILE))
  end


  # create a member with a membership fee payment, branding fee paid  return the member
  def create_member_with_member_and_branding_payments_expiring(member_pay_expires = Time.zone.today + 1.year,
                                                               payment_create_date: Time.zone.now,
                                                               membership_status: :current_member)
    u = create(:member, last_day: member_pay_expires, membership_status: membership_status)
    u.shf_application.update(created_at: payment_create_date, updated_at: payment_create_date)

    create(:payment,
            user: u,
            payment_type: Payment::PAYMENT_TYPE_BRANDING,
            status: SUCCESSFUL_PAYMENT,
            expire_date: member_pay_expires,
            created_at: payment_create_date,
            updated_at: payment_create_date)
    u.payments.each { |payment| payment.update(created_at: payment_create_date, updated_at: payment_create_date) }
    u
  end


  # create a paid up member with a given company number, make a payment with the expire date.
  def create_co_and_payment(company_number, payment_exp_date, member_pay_expires: Time.zone.today + 1.year, payment_create_date: Time.zone.now)

    u = create(:member_with_membership_app, company_number: company_number)
    u.shf_application.update(created_at: payment_create_date, updated_at: payment_create_date)

    co = u.shf_application.companies.first

    create(:payment,
           user: u,
           payment_type: Payment::PAYMENT_TYPE_MEMBER,
           status: SUCCESSFUL_PAYMENT,
           expire_date: member_pay_expires,
           created_at: payment_create_date,
           updated_at: payment_create_date)

    branding_payment = create(:payment,
                              user: u,
                              payment_type: Payment::PAYMENT_TYPE_BRANDING,
                              status: SUCCESSFUL_PAYMENT,
                              expire_date: payment_exp_date,
                              created_at: payment_create_date,
                              updated_at: payment_create_date)

    co.payments << branding_payment
    co
  end


end # DataCreationHelper
