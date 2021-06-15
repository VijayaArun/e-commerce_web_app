class Visit < ActiveRecord::Base
  belongs_to :visit_remark, foreign_key: 'remark_id'
end
