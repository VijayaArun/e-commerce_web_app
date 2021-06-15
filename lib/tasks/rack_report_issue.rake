require 'ffaker'
require 'pathname'
require 'spree/sample'

namespace :spree_sample do
  desc 'Loads salesman identifier'
  task rack_report_issue: :environment do
    RackItem.all.each do |rack_item|
      unless rack_item.variant.deleted_at.nil?
        rack_item.deleted_at = rack_item.variant.deleted_at
        rack_item.save
      end
    end
  end
end
