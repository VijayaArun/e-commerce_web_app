    module Spree
class Variant < Spree::Base
  belongs_to :User
  belongs_to :RoleUser

end
end