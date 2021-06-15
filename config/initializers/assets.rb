# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )

#For Product page
Rails.application.config.assets.precompile += %w( product.js )

#For Taxon Price page 
Rails.application.config.assets.precompile += %w( spree/custom-backend.js )
Rails.application.config.assets.precompile += %w( spree/taxon-details.js )

#For Currency on header
Rails.application.config.assets.precompile += %w( main_nav_bar.js )
Rails.application.config.assets.precompile += %w( spree/main_nav_bar.scss )

#For admin panel user creation

Rails.application.config.assets.precompile += %w( spree/admin/user.scss )
Rails.application.config.assets.precompile += %w( spree/admin/admin.scss )

#For Sending Dispatch information
Rails.application.config.assets.precompile += %w( shipment_dispatch.js )