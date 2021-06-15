class ContactUsController < ApplicationController
  include ContactUsHelper
  skip_before_filter :verify_authenticity_token, :only => [:send_email]

  def send_email
    invalids = validate_contact_us_params(params)
    if invalids.empty?
      UserMailer.send_email(params).deliver_now
      render json: {mailSent: true,
                    message: "Thank you for your message.It has been sent."
                    }.to_json
    else
      render json: {invalids: invalids,
                    mailSent: false ,
                    message: "One or more fields have an error. Please check and try                                      again."
                    }.to_json
    end
  end
end
