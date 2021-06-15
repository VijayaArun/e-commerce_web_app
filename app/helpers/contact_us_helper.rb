module ContactUsHelper

  def validate_contact_us_params(params)
    validateFor= ["first-name", "last-name", "your-email",
                  "your-phone", "your-subject", "your-message"]
    formatValidateFor=["your-email", "your-phone", "your-message"]
    invalids={}

    params.each do |fieldName, fieldValue|
      next if !validateFor.include? fieldName.to_s
      error={}
      if params[fieldName].to_s == ""
        error['into'] = "." + fieldName.to_s
        error['message'] = "This field can not be blank."
        invalids[fieldName] = (error)
      elsif formatValidateFor.include? fieldName.to_s
        invalidFormatValidations(fieldName, fieldValue, error, invalids)
      end
    end

    return invalids
  end

  def invalidFormatValidations(fieldName, fieldValue, error, invalids)
    if fieldName == 'your-email'
      unless fieldValue =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
        error['into']="."+fieldName.to_s
        error['message']="Email is invalid."
        invalids[fieldName]=(error)
      end

    elsif fieldName == 'your-phone' && fieldValue.match(/[a-zA-Z]+/) != nil
      error['into']="."+fieldName.to_s
      error['message']="Phone is invalid."
      invalids[fieldName]=(error)

    elsif fieldName == 'your-message' && fieldValue.length <= 50
      error['into']="."+fieldName.to_s
      error['message']="Please enter Your Message greater than 50 characters. "
      invalids[fieldName]=(error)
    end
  end

end