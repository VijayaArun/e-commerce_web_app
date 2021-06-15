
collection @users
attributes :id , :email , :spree_api_key, :updated_at 

child :addresses do
 attributes  :full_name , :firstname  , :lastname, :address1 , :address2  , :default , :city , :zipcode , :phone , :alternative_phone , :state_id , :country_id , :company
end

child :vendor_detail do
  attributes :outstanding_amount
end
