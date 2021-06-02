require 'rails_helper'

RSpec.describe AdminController, type: :controller do

  # this will bypass Pundit policy access checks so logging in is not necessary
  before(:each) do
    Warden.test_mode!
    Timecop.freeze(Time.zone.parse("2019-01-01"))
  end

  after(:each) do
    Warden.test_reset!
    Timecop.return
  end

  let(:user) { create(:user) }

  let(:csv_header) { out_str = ''
  out_str << "'#{I18n.t('activerecord.attributes.shf_application.contact_email').strip}',"
  out_str << "'#{I18n.t('activerecord.attributes.user.email').strip}',"
  out_str << "'#{I18n.t('activerecord.attributes.shf_application.first_name').strip}',"
  out_str << "'#{I18n.t('activerecord.attributes.shf_application.last_name').strip}',"
  out_str << "'#{I18n.t('activerecord.attributes.user.membership_number').strip}',"
  out_str << "'#{I18n.t('activerecord.attributes.user.date_member_packet_sent').strip}',"
  out_str << "'#{I18n.t('activerecord.attributes.shf_application.state').strip}',"
  out_str << "'#{I18n.t('admin.export_ansokan_csv.date_state_changed').strip}',"
  out_str << "'#{I18n.t('activerecord.models.business_category.other').strip}',"
  out_str << "'#{I18n.t('activerecord.models.company.one').strip}',"
  out_str << "'#{I18n.t('admin.export_ansokan_csv.member_fee_paid').strip}',"
  out_str << "'#{I18n.t('admin.export_ansokan_csv.member_fee_expires').strip}',"
  out_str << "'#{I18n.t('admin.export_ansokan_csv.branding_fee_paid').strip}',"
  out_str << "'#{I18n.t('admin.export_ansokan_csv.branding_fee_expires').strip}',"
  out_str << "'#{I18n.t('activerecord.attributes.address.street').strip}',"
  out_str << "'#{I18n.t('activerecord.attributes.address.post_code').strip}',"
  out_str << "'#{I18n.t('activerecord.attributes.address.city').strip}',"
  out_str << "'#{I18n.t('activerecord.attributes.address.kommun').strip}',"
  out_str << "'#{I18n.t('activerecord.attributes.address.region').strip}',"
  out_str << "'#{I18n.t('activerecord.attributes.address.country').strip}'"
  out_str << "\n"
  out_str }

  let(:expected_pattern) { /(.*)\n(.*),(.*),(.*),(.*),(.*),(.*),(.*),([^"]*),"([^"]*)","([^"]*)","([^"]*)","([^"]*)","([^"]*)","([^"]*)","([^"]*)",'(.*),"([^"]*)",(.*),(.*),(.*)\n/m }

  let(:payment_successful) { 'betald' }
  let(:payment_expiry_20191108) { Time.zone.parse("2019-11-08") }


  describe '#export_ankosan_csv' do

    # These are the positions of each item (column) ASSUMING THERE IS 1 BUSINESS CATEGORY
    # The constants are here so that when items are changed or moved, these tests aren't quite so brittle.

    # These are NOT ZERO BASED (because the Regexp matcher position [0] is the _entire string_)
    SHF_CONTACT_EMAIL  = 1
    LOGIN_EMAIL        = 2
    FIRST_NAME         = 3
    LAST_NAME          = 4
    MEMBERSHIP_NUM     = 5
    DATE_MEMBER_PACKET_SENT = 6
    APPLICATION_STATUS = 7
    APP_LAST_UPDATE    = 8
    BUS_CATEGORY_START = 9 # if there is more than 1 business category, the positions of the following columns are different
    # (ex: shifted by the number of additional business categories)
    COMPANY_NAME          = 10
    MEMBERSHIP_FEE_STATUS = 11
    MEMBERSHIP_EXP_DATE   = 12
    BRANDING_FEE_STATUS   = 13
    BRANDING_LIC_EXP_DATE = 14
    ADDR_STREET           = 15
    ADDR_POSTCODE         = 16
    ADDR_CITY             = 17
    ADDR_KOMMUN           = 18
    ADDR_COUNTY           = 19
    ADDR_COUNTRY          = 20


    # This lets us do the post: just once and then memoize the response body.
    # export_response_body must be referred first in the test so that this is called at least once.
    let(:export_response_body) do
      post :export_ansokan_csv
      response.body
    end


    describe 'logged in as admin' do

      it 'content type is text/csv' do

        post :export_ansokan_csv

        expect(response.content_type).to eq 'text/plain'

      end


      describe 'with 0 membership applications' do

        it 'no membership applications has just the header' do

          export_response_body

          expect(export_response_body).to eq csv_header

        end

      end


      def paid_or_payment_url(membership_is_current, payment_path)
        membership_is_current ? I18n.t('admin.export_ansokan_csv.paid') : I18n.t('admin.export_ansokan_csv.fee_payment_url', payment_url: payment_path)
      end


      # return 'never paid' if arg isNil else the arg.to_s
      def never_paid_if_blank(arg)
        arg.blank? ? I18n.t('admin.export_ansokan_csv.never_paid') : arg.to_s
      end


      describe 'with 1 app for each membership state' do

        it 'includes all applications' do

          result_str = csv_header

          # create 1 application in each state
          ShfApplication.aasm.states.each do |app_state|

            u = FactoryBot.create(:user,
                                  first_name: "First#{app_state.name}",
                                  last_name:  "Last#{app_state.name}",
                                  email:      "#{app_state.name}@example.com")

            m = FactoryBot.create :shf_application,
                                  contact_email: "#{app_state.name}@example.com",
                                  state:         app_state.name,
                                  user:          u

            member1_info = "#{m.contact_email},#{u.first_name},#{u.last_name},#{u.membership_number},#{u.date_membership_packet_sent}," + I18n.t("shf_applications.state.#{app_state.name}")


            result_str << member1_info + ','

            # state date
            result_str << (m.updated_at.strftime('%F'))
            result_str << ','
            result_str << ','

            result_str << "\"#{m.business_categories[0].name}\","

            result_str << (m.companies.empty? ? '' : '"' + m.companies.last.name + '"')

            result_str << ','

            # Membership Fee
            # say Paid if member fee is paid, otherwise make link to where it is paid
            result_str << '"' + paid_or_payment_url(u.payments_current?, user_path(u)) + '"'
            result_str << ','
            result_str << '"' + (never_paid_if_blank(m.user.membership_expire_date)) + '",'
            result_str << ','

            # H-branding fee
            if m.companies.empty?
              result_str << "-,#{I18n.t('admin.export_ansokan_csv.never_paid')},"
            else
              # say betald if branding fee is paid, otherwise makes link to where it is paid (when logged in)
              result_str << '"' + paid_or_payment_url(m.companies.last.branding_license?, company_path(m.companies.last.id)) + '"'
              result_str << ','
              result_str << '"' + (never_paid_if_blank(m.user.membership_expire_date)) + '",'
            end


            result_str << m.se_mailing_csv_str + "\n"

          end

          post :export_ansokan_csv

          # 8 lines
          expected_pattern = /(.*)\n(.*)\n(.*)\n(.*)\n(.*)\n(.*)\n(.*)\n(.*)\n/m

          expect(response.body).to match expected_pattern

        end

      end


      describe 'columns correct with simple results' do


        let(:u1) { FactoryBot.create(:member,
                                     first_name:        "u1",
                                     email:             "user1@example.com",
                                     membership_number: '1234567890',
                                     date_membership_packet_sent: '2019-07-07',
                                     expiration_date: payment_expiry_20191108,
                                     contact_email: 'u1@example.com')
        }

        let(:branding_payment) do
          FactoryBot.create(:payment,
                            status:       payment_successful,
                            user:         u1,
                            company:      u1.companies.first,
                            payment_type: Payment::PAYMENT_TYPE_BRANDING,
                            expire_date:  payment_expiry_20191108)
        end


        let(:csv_response) do
          branding_payment.save

          post :export_ansokan_csv
          response.body
        end

        let(:expected_pattern) { /(.*)\n(.*),(.*),(.*),(.*),(.*),(.*),(.*),([^"]*),"([^"]*)","([^"]*)","([^"]*)","([^"]*)","([^"]*)","([^"]*)","([^"]*)",'(.*),"([^"]*)",(.*),(.*),(.*)\n/m }

        let(:pattern_matches) { csv_response.match expected_pattern }


        # Note that the first item matched is the header line.
        #  That's why each of the positions (array indices) below have a +1

        # -/(.*)\n(.*),(.*),(.*),(.*),(.*),(.*),(.*),([^"]*),"([^"]*)","([^"]*)","([^"]*)","([^"]*)","([^"]*)","([^"]*)","([^"]*)",'(.*),"([^"]*)",(.*),(.*),(.*)\n/m
        # +'Kontakt e-post','E-post för inloggning','Förnamn','Efternamn','Medlemsnummer','Date Member Packet sent','Status','Date State changed','Kategorier','Företag','M fee paid','M Expires','H-brand paid','H Expires','Gata','Post nr.','Ort','Kommun','Verksamhetslän','Land'
        # +[0]u1@example.com,[1]user1@example.com,[2]u1,[3]Lastname,[4]1234567890,[5]2019-07-07,[6]Godkänd,[7]2019-03-16,[8]"Business Category",[9]false,[10]"Betald",[11]"2019-11-08",[12]"Betald",[13]"2019-11-08",[14]"Hundforetagarevägen 1",'310 40,"Harplinge",Ale,MyString,Sverige

        it 'the result matches the header and expected number of fields' do
          expect(csv_response).to match expected_pattern
        end

        it 'contact email' do
          expect(pattern_matches[SHF_CONTACT_EMAIL + 1]).to eq 'u1@example.com'
        end

        it 'login email for the application user' do
          expect(pattern_matches[LOGIN_EMAIL + 1]).to eq 'user1@example.com'
        end

        it 'first name' do
          expect(pattern_matches[FIRST_NAME + 1]).to eq 'u1'
        end

        it 'last name' do
          expect(pattern_matches[LAST_NAME + 1]).to eq 'Lastname'
        end

        it 'membership number' do
          expect(pattern_matches[MEMBERSHIP_NUM + 1]).to eq '1234567890'
        end

        it 'date member packet sent' do
          expect(pattern_matches[DATE_MEMBER_PACKET_SENT + 1]).to eq '2019-07-07'
        end

        it 'application status' do
          expect(pattern_matches[APPLICATION_STATUS + 1]).to eq 'Godkänd'
        end

        it 'date of state (application status last update)' do
          expect(pattern_matches[APP_LAST_UPDATE + 1]).to eq Time.zone.now.strftime("%Y-%m-%d")
        end

        it 'company name' do
          expect(pattern_matches[COMPANY_NAME + 1]).to eq 'SomeCompany'
        end

        it 'membership fee status' do
          expect(pattern_matches[MEMBERSHIP_FEE_STATUS + 1]).to eq 'Betald'
        end

        it 'membership expiration date' do
          expect(pattern_matches[MEMBERSHIP_EXP_DATE + 1]).to eq '2019-11-08'
        end

        it 'branding fee status' do
          expect(pattern_matches[BRANDING_FEE_STATUS + 1]).to eq 'Betald'
        end

        it 'branding license expiration date' do
          expect(pattern_matches[BRANDING_LIC_EXP_DATE + 1]).to eq '2019-11-08'
        end

        it 'street' do
          expect(pattern_matches[ADDR_STREET + 1]).to eq 'Hundforetagarevägen 1'
        end

        it 'post code' do
          expect(pattern_matches[ADDR_POSTCODE + 1]).to eq '310 40'
        end

        it 'ort/city' do
          expect(pattern_matches[ADDR_CITY + 1]).to eq 'Harplinge'
        end

        it 'kommun' do
          expect(pattern_matches[ADDR_KOMMUN + 1]).to eq 'Ale'
        end

        it 'Verksamhetslän/county' do
          expect(pattern_matches[ADDR_COUNTY + 1]).to eq 'MyString'
        end

        it 'country' do
          expect(pattern_matches[ADDR_COUNTRY + 1]).to eq 'Sverige'
        end


      end


      describe 'with business categories (surrounded by double quotes)' do

        let(:u1) { FactoryBot.create(:user,
                                     first_name:        "u1",
                                     email:             "user1@example.com",
                                     membership_number: '1234567890')
        }

        let(:c1) { FactoryBot.create(:company) }

        let(:shf_app1) { FactoryBot.create :shf_application,
                                           contact_email: "u1@example.com",
                                           state:         :accepted,
                                           user:          u1
        }

        let(:csv_response) do
          post :export_ansokan_csv
          response.body
        end


        let(:shf_app1_info) { "#{shf_app1.contact_email},#{u1.first_name},#{u1.last_name},#{u1.membership_number}," + I18n.t("shf_applications.state.#{shf_app1.state}") }

        let(:expected_pattern_with_email) { /(.*)\n([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^"^,]*),"",(.*),(.*),(.*),(.*),(.*),#{c1.se_mailing_csv_str}/ }

        let(:pattern_before_categories) { /(.*),(.*),(.*),(.*),(.*),(.*),(.*),/ }

        let(:pattern_after_categories_with_email) { /(.*),(.*),(.*),(.*),(.*),#{c1.se_mailing_csv_str}/ }


        it 'zero/nil business categories' do

          user_no_categories = FactoryBot.create(:user)

          shf_app_no_categories                     = FactoryBot.create(:shf_application,
                                                                        user: user_no_categories)
          shf_app_no_categories.business_categories = []

          expect(csv_response).to match(expected_pattern_with_email)
        end


        it 'one business category' do

          shf_app1.save
          expect(csv_response).to match(Regexp.new(pattern_before_categories.to_s +
                                                       "\"#{shf_app1.business_categories[0].name}\"" +
                                                       pattern_after_categories_with_email.to_s))
        end


        it 'three business categories, each separated by a comma then space' do

          shf_app1.business_categories = [create(:business_category, name: 'Category1')]
          shf_app1.business_categories << create(:business_category, name: 'Category 2')
          shf_app1.business_categories << create(:business_category, name: 'Category the third')

          shf_app1.save

          result_regexp = Regexp.new(pattern_before_categories.to_s +
                                         "\"([^\"]*)\"," +
                                         pattern_after_categories_with_email.to_s)

          expect(csv_response).to match result_regexp

          # Check that the categories are as expected:
          match = csv_response.match result_regexp

          # get the categories from the (.*) group -- if there are any
          #   get rid of extra quotes and whitespace
          match.to_a.size > 7 ? categories = match[8].delete('"').split(',').map(&:strip) : categories = []

          # expect all categories to be there, but could be in any order
          expect(categories).to match_array(['Category1', 'Category 2', 'Category the third'])
        end
      end


      describe 'error from send_data is rescued' do
        let(:error_message) { 'Error. Error. Warning Will Robinson' }

        subject do
          allow(@controller).to receive(:send_data) { raise StandardError.new(error_message) }
          post :export_ansokan_csv
        end

        it 'redirects to back or the root path' do
          expect(subject).to redirect_to root_path
        end

        it "flashes an error :alert message" do
          expect(subject.request.flash[:alert]).to_not be_nil
          expect(subject.request.flash[:alert]).to eq ["#{I18n.t('admin.export_ansokan_csv.error')}"]
        end
      end


      describe 'includes membership expiry date' do

        it "no membership expiry date shows wording and url to pay and 'never paid'" do
          user_with_app = FactoryBot.create(:user_with_membership_app)

          user_app = user_with_app.shf_application
          user_app.save

          post :export_ansokan_csv

          never_paid    = I18n.t('admin.export_ansokan_csv.never_paid')
          pay_using_url = I18n.t('admin.export_ansokan_csv.fee_payment_url', payment_url: user_path(user_with_app))

          expected_pattern = /(.*)\n(.*),(.*),(.*),(.*),(.*),(.*),([^"]*),"([^"]*)","([^"]*)","(#{pay_using_url})","(#{never_paid})","([^"]*)","([^"]*)","([^"]*)",'(.*),"([^"]*)",(.*),(.*),(.*)/m

          expect(response.body).to match expected_pattern
        end
      end


      describe 'includes H-branding expiry date' do

        it "no H-brand license expiry date shows wording and url to pay and 'never paid'" do

          user_with_app = FactoryBot.create(:user_with_membership_app)

          user_app = user_with_app.shf_application

          user_with_app.save
          user_app.save

          post :export_ansokan_csv

          never_paid    = I18n.t('admin.export_ansokan_csv.never_paid')
          pay_using_url = I18n.t('admin.export_ansokan_csv.fee_payment_url', payment_url: company_path(user_app.companies.last.id))

          expected_pattern = /(.*)\n(.*),(.*),(.*),(.*),(.*),(.*),([^"]*),"([^"]*)","([^"]*)","([^"]*)","([^"]*)","(#{pay_using_url})","(#{never_paid})","([^"]*)",'(.*),"([^"]*)",(.*),(.*),(.*)\n/m

          expect(response.body).to match expected_pattern

        end

      end

    end

  end # '#export_ankosan_csv'

end
