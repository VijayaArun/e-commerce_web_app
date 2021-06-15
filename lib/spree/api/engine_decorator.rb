module Spree
  module Api
    Engine.class_eval do 
      config.after_initialize do
        VersionCake.setup do |config|
          #Allow version 2 for products api
          config.versioned_resources.unshift VersionCake::VersionedResource.new(%r{/products}, [], [], [1, 2])
        end
      end
    end
  end
end
