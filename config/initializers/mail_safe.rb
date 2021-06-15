if defined?(MailSafe::Config)
  MailSafe::Config.internal_address_definition = /.*@hmsilsdf\.com/i
  MailSafe::Config.replacement_address = 'solidusproduction@gmail.com'
end