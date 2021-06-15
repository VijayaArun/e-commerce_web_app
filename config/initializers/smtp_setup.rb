ActionMailer::Base.smtp_settings = {
  :address              => ENV['MAILER_ADDRESS'],
  :port                 => ENV['MAILER_PORT'].to_i,
  :domain               => ENV['MAILER_DOMAIN'],
  :user_name            => ENV['MAILER_USERNAME'],
  :password             => ENV['MAILER_PASSWORD'],
  :authentication       => ENV['MAILER_AUTHENTICATION'].to_sym,
  :enable_starttls_auto => true
}

ActionMailer::Base.default_url_options = {
  host: 'http://localhost:3000'
}

ActionMailer::Base.delivery_method = Rails.env == 'production' ? :smtp  : :letter_opener