# this needs to be require_relative because this file is also used by the Cucumber featers
require_relative '../spec_helper'

# Mock for AdminOnly::AppConfiguration
# Mock for attachments, urls, and paths used with AppConfiguration
#
# Because AdminOnly::AppConfiguration is queried is nearly every test,
# there is value in mocking it and stubbing the methods to give us great
# speed-up in testing.
# Creating the AppConfiguration attachments is quite slow (relative to
# testing times). Multiply creating the attachments times each time an
# AppConfiguration is created for so many test and it's a lot of time.
# Thus using a mock (or mocks) speeds up testing considerably.
#
# See the before(:each) block in rails_helper.rb where this is used.


class FauxPath
  def self.path
    '/path/to/the/image_filename.jpg'
  end
end

class FauxUrl
  def self.url
    '/public/storage/path/to/the/image_filename.jpg'
  end
end


class MockAttachment

  # Ignore any arguments. Always just return the Faux url
  def self.url(*_args)
    FauxUrl.url
  end

  def self.path
    FauxPath.path
  end
end

class MockAttachmentForFile

  # file_path is relative to Rails.root
  def initialize(file_path)
    @filepath = file_path
  end

  def path
    @filepath
  end

  def url
    @filepath
  end
end

# add stubbed methods here as needed for testing
class MockAppConfig

  # ------------------------------
  # Images (Paperclip attachments and associated methods)

  stubbed_attachment_methods = ['content_type'.freeze,
                                'file_name'.freeze,
                                'file_path'.freeze,
                                'file_url'.freeze,
                                'file_size'.freeze,
                                'width'.freeze,
                                'height'.freeze].freeze


  # create the stubbed methods for each image attachment
  AdminOnly::AppConfiguration.image_attributes.each do |stubbed_image_attachment|

    class_eval %{ def self.#{stubbed_image_attachment}; default_image; end }, __FILE__, __LINE__

    stubbed_attachment_methods.each do |method_name|
      class_eval %{ def self.#{stubbed_image_attachment}_#{method_name}; default_image_#{method_name}; end }, __FILE__, __LINE__
    end

  end


  def self.site_name
    'site name'
  end


  def self.site_meta_title
    'site title'
  end


  def self.site_meta_description
    'site meta description'
  end


  def self.site_meta_keywords
    'site meta keywords'
  end


  def self.email_admin_new_app_received_enabled
    true
  end

  def self.og_type
    'og type'
  end

  def self.twitter_card_type
    'twitter card type'
  end

  def self.facebook_app_id
    1234567890
  end

  def self.payment_too_soon_days
    60
  end

  def self.membership_expired_grace_period_duration
    ActiveSupport::Duration.parse('P90D')
  end

  def self.membership_term_duration
    ActiveSupport::Duration.parse('P1Y')
  end

  def self.membership_expiring_soon_days
    42
  end

  # ----------------------------------------------------
  #  Default results to use to stub methods

  def self.default_image_content_type
    'image/png'
  end


  def self.default_image_file_name
    'image.png'
  end


  def self.default_image_file_path
    # TODO: do we need to ensure that the file exists here?  If so, copy it from fixture_file  to here (use lazy initialization)
    File.join(Rails.public_path, 'storage', 'images', default_image_file_name)
  end


  def self.default_image_file_url
    # TODO: do we need to ensure that the file exists here?  If so, copy it from fixture_file  to here (use lazy initialization)
    "/storage/app_configuration/images/#{default_image_file_name}"
  end


  def self.default_image_file_size
    2292
  end


  def self.default_image_width
    80
  end


  def self.default_image_height
    80
  end


  def self.default_image
    MockAttachment
  end

end



RSpec.shared_context 'mock AppConfiguration' do

  # use this instead of creating or building an AppConfiguration
  let(:mock_app_config) { MockAppConfig }

end
