attachment_config = {

  s3_credentials: {
    access_key_id:     ENV['AWS_MUMBAI_ACCESS_KEY_ID'],
    secret_access_key: ENV['AWS_MUMBAI_SECRET_ACCESS_KEY'],
    bucket:            ENV['S3_MUMBAI_BUCKET_NAME']
  },

  storage:        :s3,
  s3_headers:     { "Cache-Control" => "max-age=31557600" },
  s3_protocol:    "https",
  s3_region:      ENV['AWS_REGION'],
  s3_host_name:   ENV['S3_HOST_NAME'],
  s3_host_alias:  ENV['S3_MUMBAI_BUCKET_NAME'],
  bucket:         ENV['S3_MUMBAI_BUCKET_NAME'],

  styles: {
    mini:     "48x48>",
    small:    "100x100>",
    product:  "240x240>",
    large:    "600x600>"
  },

  path:          "/products/:id/:style/:basename.:extension",
  default_url:   "noimage/:style.png",
  default_style: "product",
}

attachment_config.each do |key, value|
   Spree::Image.attachment_definitions[:attachment][key.to_sym] = value
end unless Rails.env.test?