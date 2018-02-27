class ApplicationMailer < ActionMailer::Base
  default from: ENV['Mailer_Email']
  layout 'mailer'
end
