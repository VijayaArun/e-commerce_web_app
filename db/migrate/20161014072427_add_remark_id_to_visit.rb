class AddRemarkIdToVisit < ActiveRecord::Migration
  def change
    add_reference :visits, :remark, index: true, foreign_key: true
  end
end