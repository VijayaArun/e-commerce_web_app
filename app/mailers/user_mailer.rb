class UserMailer < ActionMailer::Base
  default from: ENV['MAILER_USERNAME']

  def welcome(user)
    @user = user
    mail(to: @user.email, subject: 'Welcome to the Awesome Site')
  end

  def send_email(params)
    mail(to: ENV['WEBSITE_CONTACT_US_EMAIL_TO'], subject: params['your-subject']) do |format|
      format.html {
        render locals: {
            first_name: params['first-name'],
            last_name: params['last-name'],
            mobile_num: params['your-phone'],
            your_message: params['your-message'],
            your_email:params['your-email'] }
      }
    end
  end
end