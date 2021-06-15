require 'ffaker'
require 'pathname'
require 'spree/sample'

namespace :spree_sample do
  desc 'Loads salesman identifier'
  task fix_sample_issues: :environment do
    users = [
  {
    email: "salesman@shreesarees.com",
    role: "salesman",
    salesman_identifier: "SAL"
  },
  {
    email: "salesman2@shreesarees.com",
    role: "salesman",
    salesman_identifier: "SALA"
  },
  {
    email: "babu@shreesarees.com",
    role: "salesman",
    salesman_identifier: "BG"
  },
  {
    email: "ssadi@shreesarees.com",
    role: "salesman",
    salesman_identifier: "GS"
  },
  {
    email: "bmshah@shreesarees.com",
    role: "salesman",
    salesman_identifier: "BS"
  },
  {
    email: "rakesh@shreesarees.com",
    role: "salesman",
    salesman_identifier: "RG"
  },
  {
    email: "cvshah1803@gmail.com",
    role: "salesman",
    salesman_identifier: "CV"
  }
]
    Spree::User.all.each do |user_attrs|
      if (user_attrs.role.name == "salesman")
        if user_attrs.salesman_details.present?
          users.each do |u|
            if (user_attrs.email == u[:email])
              identifier = u[:salesman_identifier]
              if(user_attrs.email != u[:email] && SalesmanDetails.where(identifier: identifier).exists?)
                user_attrs.salesman_details.identifier = (identifier << ("A").to_s)
              else
                user_attrs.salesman_details.identifier = identifier
              end
              user_attrs.salesman_details.save
            end
          end
        end
      end
    end
  end
end
