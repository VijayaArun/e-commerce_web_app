collection @user
attributes :id , :encrypted_password , :password_salt, :email , :spree_api_key , :created_by_id, :updated_at

child :vendor_detail do
  attributes :id, :user_id, :salesman_id
end

child :addresses do
 attributes  :full_name , :firstname  , :lastname, :address1 , :address2  , :default , :city , :zipcode , :phone , :alternative_phone , :company , :state_id , :country_id 
end