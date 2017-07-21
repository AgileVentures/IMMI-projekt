class ApplicationMailer < ActionMailer::Base
  default from: ENV['SHF_NOREPLY_EMAIL']
  layout 'mailer'
end
