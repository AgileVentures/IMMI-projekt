require 'rails_helper'
require 'email_spec/rspec'


RSpec.describe ShfAppNoUploadedFilesAlert do

  let(:nov30) { Time.utc(2018, 11, 30) }
  let(:dec1)  { Time.utc(2018, 12, 1) }
  let(:dec7)  { Time.utc(2018, 12, 7) }

  let(:user) { create(:user, email: FFaker::InternetSE.disposable_email) }

  let(:condition) { create(:condition, :after, config: { days: [1, 7] }) }

  let(:config) { { days: [1, 7] } }

  let(:timing) { ShfAppNoUploadedFilesAlert::TIMING_AFTER }

  let(:alert_days) { [ dec1, dec7 ] }


  describe '.send_alert_this_day?(config, user)' do

    APP_STATE_STILL_NEEDING_UPLOADS = ShfAppNoUploadedFilesAlert::APP_STATES_WAITING_FOR_FILES

    OTHER_STATES = ShfApplication.all_states.map(&:to_s) - APP_STATE_STILL_NEEDING_UPLOADS

    it 'false if no application' do
      expect(described_class.instance.send_alert_this_day?(timing, config, user)).to be_falsey
    end


    describe 'only send if application is in a state waiting for files' do

      context "application state not one of #{APP_STATE_STILL_NEEDING_UPLOADS}" do
        OTHER_STATES.each do | app_state |

          let(:applicant) do
            u = create(:user_with_membership_app)
            u.shf_application.state = app_state
            u
          end

          it 'false even if today is in the list of alert days' do
            # ensure that the updated_at date is Nov 30
            Timecop.freeze(nov30) do
              applicant
            end

            Timecop.freeze(dec1) do
              expect(Date.current - applicant.shf_application.updated_at.to_date).to eq 1
              expect(described_class.instance.send_alert_this_day?(timing, { days: [1] }, applicant)).to be_falsey
            end

          end
        end
      end

      context "application state IS one of  #{APP_STATE_STILL_NEEDING_UPLOADS}" do

        APP_STATE_STILL_NEEDING_UPLOADS.each do | app_state |

          let(:applicant) do
            u = create(:user_with_membership_app)
            u.shf_application.state = app_state
            u
          end

          it 'false if today - shf_app.updated_at date is not in the list of days' do
            # ensure that the updated_at date is Nov 30
            Timecop.freeze(nov30) do
              applicant
            end

            Timecop.freeze(dec1) do
              expect(described_class.instance.send_alert_this_day?(timing, { days: [999] }, applicant)).to be_falsey
            end
          end

          it 'true if today - shf_app.updated_at date IS in the list of days' do
            # ensure that the updated_at date is Nov 30
            Timecop.freeze(nov30) do
              applicant
            end

            alert_days.each do | alert_date |
              Timecop.freeze(alert_date) do
                expect(described_class.instance.send_alert_this_day?(timing, config, applicant)).to be_truthy
              end

            end
          end
        end

      end

    end


  end


  describe 'file_delivery_method is nil (can happen with applications created before we implemented file_delivery_method)' do

    let(:applicant) { create(:user_with_membership_app) }


    it "do send if file delivery method = nil (and we should send it this day)" do

      # ensure that the updated_at date is Nov 30
      Timecop.freeze(nov30) do
        applicant
        applicant.shf_application.file_delivery_method = nil
      end

      alert_days.each do | alert_date |
        Timecop.freeze(alert_date) do
          expect(described_class.instance.send_alert_this_day?(timing, config, applicant)).to be_truthy
        end
      end
    end

  end


  context 'no files uploaded' do

    let(:applicant) { create(:user_with_membership_app) }

    it "don't send if they said they would email them" do

      # ensure that the updated_at date is Nov 30
      Timecop.freeze(nov30) do
        applicant
        applicant.shf_application.file_delivery_method = create(:file_delivery_email)
      end

      alert_days.each do | alert_date |
        Timecop.freeze(alert_date) do
          expect(described_class.instance.send_alert_this_day?(timing, config, applicant)).to be_falsey
        end
      end
    end


    it "don't send if they said they would (postal) mail them" do

      # ensure that the updated_at date is Nov 30
      Timecop.freeze(nov30) do
        applicant
        applicant.shf_application.file_delivery_method = create(:file_delivery_mail)
      end

      alert_days.each do | alert_date |
        Timecop.freeze(alert_date) do
          expect(described_class.instance.send_alert_this_day?(timing, config, applicant)).to be_falsey
        end
      end
    end

    describe "send for other delivery methods" do

      other_delivery_methods = AdminOnly::FileDeliveryMethod::METHOD_NAMES.keys.reject{|key| key == :email || key == :mail || key == :upload_now }
      other_delivery_methods.each do | delivery_method_name |

        it "do send for method #{delivery_method_name}" do

          # ensure that the updated_at date is Nov 30
          Timecop.freeze(nov30) do
            applicant
            applicant.shf_application.file_delivery_method = create("file_delivery_#{delivery_method_name}".to_sym)
          end

          alert_days.each do | alert_date |
            Timecop.freeze(alert_date) do
              expect(described_class.instance.send_alert_this_day?(timing, config, applicant)).to be_truthy
            end
          end
        end

      end

    end

  end


  describe "don't send if files were uploaded" do

    let(:applicant) { create(:user_with_membership_app) }

    it "1 file uploaded" do
      # ensure that the updated_at date is Nov 30
      Timecop.freeze(nov30) do
        applicant
        #  applicant.shf_application.file_delivery_method = create("file_delivery_#{delivery_method_name}".to_sym)

        UPLOAD_FIXTURES_DIR = File.join(Rails.root, 'spec', 'fixtures','uploaded_files')
        fn1 = File.join(UPLOAD_FIXTURES_DIR, 'diploma.pdf')
        applicant.shf_application.uploaded_files.create(actual_file: File.open(fn1, 'r') )

      end

      alert_days.each do | alert_date |
        Timecop.freeze(alert_date) do
          expect(described_class.instance.send_alert_this_day?(timing, config, applicant)).to be_falsey
        end
      end
    end

  end


  it '.mailer_method' do
    expect(described_class.instance.mailer_method).to eq :app_no_uploaded_files
  end

end
