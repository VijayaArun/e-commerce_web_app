users = [
  {
    password: "shree5arees",
    email: "admin@shreesarees.com",
    role: "admin"
  },
  {
    password: "sales@123",
    email: "salesman@shreesarees.com",
    role: "salesman"
  },
  {
    password: "sales@123",
    email: "salesman2@shreesarees.com",
    role: "salesman"
  },
  {
    password: "test@123",
    email: "dispatcher@shreesarees.com",
    role: "dispatcher"
  },
  {
    password: "test@123",
    email: "sampleretailer@shreesarees.com",
    role: "vendor",
    salesman: "salesman@shreesarees.com"
  },
  {
    password: "test@123",
    email: "dummyretailer@shreesarees.com",
    role: "vendor",
    salesman: "salesman2@shreesarees.com"
  },
  {
    password: "lal@882",
    email: "babu@shreesarees.com",
    role: "salesman"
  },
  {
    password: "sman@123",
    email: "ssadi@shreesarees.com",
    role: "salesman"
  },
  {
    password: "bm5@909",
    email: "bmshah@shreesarees.com",
    role: "salesman"
  },
  {
    password: "rack3@829",
    email: "rakesh@shreesarees.com",
    role: "salesman"
  },
  {
    password: "sman@123",
    email: "cvshah1803@gmail.com",
    role: "salesman"
  }
]

default_user = Spree::User.find_by(email: 'admin@example.com')

if (default_user)
  default_user.password="shree5arees"
  default_user.save
end

users.each do |user_attrs|
  if user_attrs[:role]
    user_attrs[:role] = Spree::Role.find_by_name!(user_attrs[:role])

    if user_attrs[:salesman]
      associated_salesman = user_attrs[:salesman]
      user_attrs.except!(:salesman)
    end
    user = Spree::User.create!(user_attrs)
    user.generate_spree_api_key!
    if (user_attrs[:role].name == "salesman")
      if user.salesman_details.present?
        user.salesman_details.identifier = user.set_uniq_identifier(user_attrs[:email])
      else
        SalesmanDetails.create(user_id: user.id , identifier: user.set_uniq_identifier(user_attrs[:email]))
      end
    end
    if (user_attrs[:role].name == "vendor")
      user_id = user.id
      current_user_id = Spree::User.find_by(email: associated_salesman).id
      VendorDetail.create(user_id: user_id , salesman_id: current_user_id)

      Spree::Address.all.each do |user_address|
        if(!Spree::UserAddress.where(user_id: user_id).exists? && !Spree::UserAddress.where(address_id: user_address.id).exists?)
          Spree::UserAddress.create(user_id: user_id , address_id: user_address.id, default: true)
        end
      end
      current_user_address_id = Spree::UserAddress.find_by(user_id: user.id).id
      user.bill_address_id = current_user_address_id
      user.ship_address_id = current_user_address_id
      user.save
    end
  end
end

