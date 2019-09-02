# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
Rails.application.config.assets.precompile += %w( style.css )
Rails.application.config.assets.precompile += %w( custom.css )
Rails.application.config.assets.precompile += %w( custom-shf-application-state.scss )
Rails.application.config.assets.precompile += %w( users.scss )
Rails.application.config.assets.precompile += %w{ maps.scss }
Rails.application.config.assets.precompile += %w{ companies.scss }
Rails.application.config.assets.precompile += %w( ckeditor/config.js )
Rails.application.config.assets.precompile += %w( ckeditor/contents.css )
Rails.application.config.assets.precompile += %w{ shf-documents.scss }
Rails.application.config.assets.precompile += %w( shf-applications.scss )
Rails.application.config.assets.precompile += %w( application-mailer.scss )
Rails.application.config.assets.precompile += %w( proof-of-membership.css )
Rails.application.config.assets.precompile += %w( company-h-brand.css )
Rails.application.config.assets.precompile += %w( custom-menu.css )
