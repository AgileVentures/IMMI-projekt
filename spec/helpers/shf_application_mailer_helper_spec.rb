require 'rails_helper'

RSpec.describe ShfApplicationMailerHelper, type: :helper do

  describe '#shf_app_to_html' do

    let(:shf_app) { create(:shf_application,
                           contact_email:  'contact@example.com',
                           phone_number:   '1234567 890',
                           company_number: '2548397971',
                           num_categories: 2
    ) }

    let(:shf_app_html) { helper.shf_app_to_html(shf_app) }

    it 'user full name' do
      expect(shf_app_html).to match(/Firstname Lastname/)
    end

    it 'login email' do
      expect(shf_app_html).to match(/email_(\d*)@random.com/)
    end

    it 'contact email' do
      expect(shf_app_html).to match(/contact@example.com/)
    end

    it 'phone number' do
      expect(shf_app_html).to match(/1234567 890/)
    end

    it 'company number' do
      expect(shf_app_html).to match(/2548397971/)
    end

    it 'business categories' do
      expect(shf_app_html).to match(/Business Category 1, Business Category 2/)
    end


    describe 'file delivery choice' do

      it 'has the file delivery method intro text' do
        expect(shf_app_html).to match(/#{I18n.t('mailers.shf_application_mailer.acknowledge_received.upload_choice_intro') }/)
      end


      AdminOnly::FileDeliveryMethod::METHOD_NAMES.keys.each do | delivery_method |

        it "#{delivery_method}" do
          # DatabaseCleaner may have emptied the FileDeliverMethod table, so create the delivery method if needed
          create("file_delivery_#{delivery_method}".to_sym) if AdminOnly::FileDeliveryMethod.get_method(delivery_method).nil?

          shf_app.file_delivery_method =  AdminOnly::FileDeliveryMethod.get_method(delivery_method)
          expect(helper.shf_app_to_html(shf_app)).to match(/#{shf_app.file_delivery_method.description_for_locale(I18n.locale)}/)
        end
      end

    end


    context 'no files uploaded' do

      let(:shf_app_no_files) { create(:shf_application,
                                      contact_email:  'contact@example.com',
                                      phone_number:   '1234567 890',
                                      company_number: '2548397971',
                                      num_categories: 2
      ) }

      let(:shf_app_no_files_html) { helper.shf_app_to_html(shf_app_no_files) }

      it 'no files uploaded string' do
        expect(shf_app_no_files_html).to match(/#{I18n.t('shf_applications.uploads.no_files')}/)
        expect(shf_app_no_files_html).not_to match(/#{I18n.t('shf_applications.uploads.files_uploaded')}/)
      end

      it 'no files are listed' do
        expect(shf_app_no_files_html).not_to match(/file-upload-filename/) # CSS class used for each file
      end
    end

    context 'some files uploaded' do

      let(:shf_app_some_files) { shf_app = create(:shf_application,
                                                  contact_email:  'contact@example.com',
                                                  phone_number:   '1234567 890',
                                                  company_number: '2548397971',
                                                  num_categories: 2)
      fn1 = file_fixture('diploma.pdf')
      shf_app.uploaded_files << create(:uploaded_file_for_application, actual_file: File.open(fn1, 'r'), shf_application: shf_app)
      fn2 = file_fixture('image.jpg')
      shf_app.uploaded_files << create(:uploaded_file_for_application, actual_file:  File.open(fn2, 'r'), shf_application: shf_app)
      fn3 = file_fixture('image.gif')
      shf_app.uploaded_files << create(:uploaded_file_for_application, actual_file:  File.open(fn3, 'r'), shf_application: shf_app)

      shf_app
      }

      let(:shf_app_some_files_html) { helper.shf_app_to_html(shf_app_some_files) }


      it 'files uploaded title string' do
        expect(shf_app_some_files_html).to match(/#{I18n.t('shf_applications.uploads.files_uploaded')}/)
        expect(shf_app_some_files_html).not_to match(/#{I18n.t('shf_applications.uploads.no_files')}/)
      end

      it 'each file is listed' do
        expect(shf_app_some_files_html).to match(/diploma.pdf/)
        expect(shf_app_some_files_html).to match(/image.jpg/)
        expect(shf_app_some_files_html).to match(/image.gif/)
      end
    end

  end

end
