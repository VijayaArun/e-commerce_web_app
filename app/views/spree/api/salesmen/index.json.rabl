
collection @users
attributes :id , :email , :spree_api_key , :encrypted_password , :password_salt, :updated_at, :identifier

child :addresses do
 attributes  :full_name , :firstname  , :lastname

end

