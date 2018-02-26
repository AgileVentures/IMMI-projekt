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


  # create [num] SHF applications in the given state
  # return the list of SHF applications created
  def create_shf_apps_in_state(num, state, create_date: Time.zone.now)
    shf_apps = []

    app_transitions = [] # transition events that have to happen to put the SHF app into the correct state

    case state
      when :new
        app_transitions = [] # no transitions; initial state is correct

      when :under_review
        app_transitions = [:start_review!]

      when :waiting_for_applicant
        app_transitions = [:start_review!, :ask_applicant_for_info!]

      when :ready_for_review
        app_transitions = [:start_review!, :ask_applicant_for_info!, :is_ready_for_review!]

      when :accepted
        app_transitions = [:start_review!, :accept!]

      when :rejected
        app_transitions = [:start_review!, :reject!]

    end

    num.times do
      u = create(:user_with_membership_app)
      app_transitions.each { |transition_event| u.shf_application.send(transition_event) }
      u.shf_application.update(created_at: create_date, updated_at: create_date)

      shf_apps << u.shf_application
    end

    shf_apps
  end


  # create applications in all states and set the created_at: and updated_at dates to create_date
  # default create_date = Time.zone.now
  def create_apps_in_states(num_new: 2,
                      num_under_review: 3,
                      num_waiting_for_applicant: 4,
                      num_ready_for_review: 5,
                      num_accepted: 6,
                      num_rejected: 7,
                            create_date: Time.zone.now)

    create_shf_apps_in_state(num_new, :new, create_date: create_date)
    create_shf_apps_in_state(num_under_review, :under_review, create_date: create_date)
    create_shf_apps_in_state(num_waiting_for_applicant, :waiting_for_applicant, create_date: create_date)
    create_shf_apps_in_state(num_ready_for_review, :ready_for_review, create_date: create_date)
    create_shf_apps_in_state(num_accepted, :accepted, create_date: create_date)
    create_shf_apps_in_state(num_rejected, :rejected, create_date: create_date)
  end



  # add an uploaded file to the SHF application
  def add_uploaded_file(shf_app)
    shf_app.uploaded_files.create(actual_file: File.open(UPLOAD_PNG_FILE))
  end


  # create a member with a membership fee payment, branding fee paid  return the member
  def create_member_with_member_and_branding_payments_expiring(member_pay_expires = Time.zone.today + 1.year, payment_create_date: Time.zone.now)
    u = create(:member_with_membership_app)
    u.shf_application.update(created_at: payment_create_date, updated_at: payment_create_date)

    member_payment = create(:payment,
                            user: u,
                            payment_type: Payment::PAYMENT_TYPE_MEMBER,
                            status: SUCCESSFUL_PAYMENT,
                            expire_date: member_pay_expires)
    member_payment.update(created_at: payment_create_date, updated_at: payment_create_date)

    branding_payment  = create(:payment,
                               user: u,
                               payment_type: Payment::PAYMENT_TYPE_BRANDING,
                               status: SUCCESSFUL_PAYMENT,
                               expire_date: member_pay_expires)
    branding_payment.update(created_at: payment_create_date, updated_at: payment_create_date)

    u
  end


  # create a paid up member with a given company number, make a payment with the expire date.
  def create_co_and_payment(company_number, payment_exp_date, member_pay_expires: Time.zone.today + 1.year, payment_create_date: Time.zone.now)

    u = create(:member_with_membership_app, company_number: company_number)
    u.shf_application.update(created_at: payment_create_date, updated_at: payment_create_date)

    co = u.shf_application.company

    member_payment = create(:payment,
                            user: u,
                            payment_type: Payment::PAYMENT_TYPE_MEMBER,
                            status: SUCCESSFUL_PAYMENT,
                            expire_date: member_pay_expires)
    member_payment.update(created_at: payment_create_date, updated_at: payment_create_date)

    branding_payment = create(:payment,
                              user: u,
                              payment_type: Payment::PAYMENT_TYPE_BRANDING,
                              status: SUCCESSFUL_PAYMENT,
                              expire_date: payment_exp_date)
    branding_payment.update(created_at: payment_create_date, updated_at: payment_create_date)

    co.payments << branding_payment
    co
  end


end # DataCreationHelper
