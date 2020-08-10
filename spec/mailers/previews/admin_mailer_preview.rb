# Preview all emails at http://localhost:3000/rails/mailers

require_relative 'pick_random_helpers'


class AdminMailerPreview < ActionMailer::Preview

  include PickRandomHelpers


  def new_shf_application_received
    admin = User.find_by(admin: true)

    app = random_shf_app
    upload_random_num_files(app)

    AdminMailer.new_shf_application_received(app, admin)
  end


  def member_unpaid_over_6_months

    num_months = 6
    admin = User.find_by(admin: true)

    past_due_date = (Time.zone.now - num_months.months).to_date

    # create 3 members that are past due more than num_months:
    past_due_members = []
    3.times do |i|
      new_u = User.create(first_name: "Firstname#{i}",
                          last_name: "Lastname-#{i}",
                          email: "email-#{i}-#{Time.now.to_i}@example.com",
                          password: 'whatever',
                          admin: false,
                          member: true)
      new_u.issue_membership_number

      new_app = FactoryBot.create(:shf_application, :accepted, user: new_u)

      new_co = new_app.companies.first
      new_co.name = "Some Company #{i}" if new_co.name.blank?
      new_co.website = "http://www.woof-#{i}.com"

      # make each one overdue by (i) days + past_due_date so we have some variety
      FactoryBot.create(:membership_fee_payment,
                        user: new_u,
                        start_date: past_due_date - 364 - i,
                        expire_date: past_due_date - i)

      past_due_members << new_u
    end

    AdminMailer.member_unpaid_over_x_months(admin, past_due_members, num_months)

  end

  # Create a new member that belongs to 2 companies, 1 company has a Facebook URL and 1 does not
  def new_membership_granted_co_hbrand_paid

    # Note:  there's a problem when refreshing/re-running this.  The problem
    # is some interaction with the previewing mechanism and FactoryBot: caches for associations and reflections are not cleared and errors are raised.
    # Thus this method is a weird mix between actually creating objects and using FactoryBot.

    new_member = FactoryBot.create(:user,
                                   first_name: 'Firstname',
                                   last_name: 'JustForPreviewingEmail',
                                   email: "email-preview-#{Time.now.to_i}@random.com")

    biz_cat1 = BusinessCategory.find_or_create_by(name: 'Biz Cat1', description: 'created just to preview emails')
    biz_cat2 = BusinessCategory.find_or_create_by(name: 'Biz Cat2', description: 'created just to preview emails')

    co_with_fb_name = 'No More Snarky Barky'
    unless Company.find_by(name: co_with_fb_name)
      FactoryBot.create(:company, name: co_with_fb_name) # let FactoryBot create the org_nummer/company_number and address
    end
    co_with_facebook = Company.find_by(name: co_with_fb_name)
    #co_with_facebook.update(facebook_url: 'https://example.com/FAKE/Facebook/URL')

    co_no_fb_name = "The We Don't Use Facebook Company"
    unless Company.find_by(name: co_no_fb_name)
      FactoryBot.create(:company, name: co_no_fb_name) # let FactoryBot create the org_nummer/company_number and address
    end
    co_no_facebook = Company.find_by(name: co_no_fb_name)

    #shf_app = FactoryBot.create(:shf_application, :accepted, user: new_member)
    shf_app = ShfApplication.new(user: new_member,
                                 phone_number: '123 phone number',
                                 contact_email: 'contact@random.com',
                                 state: :accepted,
                                 when_approved: Time.zone.now,
                                 file_delivery_method: AdminOnly::FileDeliveryMethod.first,
                                 file_delivery_selection_date: Date.current
    )
    shf_app.business_categories << biz_cat1
    shf_app.business_categories << biz_cat2
    shf_app.companies << co_with_facebook
    shf_app.companies << co_no_facebook
    shf_app.save!

    FactoryBot.create(:membership_fee_payment, user: new_member)
    new_member.update(member: true)
    new_member.update(membership_number: '0123456789')

    co1 = shf_app.companies.first
    FactoryBot.create(:h_branding_fee_payment, user: new_member, company: co_with_facebook)
    #co1.update(facebook_url: 'https://example.com/FAKE/Facebook/URL')
    FactoryBot.create(:h_branding_fee_payment, user: new_member, company: co_no_facebook)

    AdminMailer.new_membership_granted_co_hbrand_paid(new_member)
  end




  def members_need_packets
    admin = User.find_by(admin: true)

    members_needing_packets = User.where(member: true, date_membership_packet_sent: nil).limit(3)

    AdminMailer.members_need_packets(admin, members_needing_packets)
  end


end
