require 'hydra/head'
require 'hydra-editor'
require 'blacklight/gallery'
require 'select2-rails'
require 'hydra-batch-edit'
require 'browse-everything'
require "sufia/version"
require 'blacklight'
require 'blacklight_advanced_search'
require 'sufia/models'
require 'sufia/inflections'
require 'sufia/arkivo'
require 'sufia/zotero'

require 'rails_autolink'
require 'font-awesome-rails'
require 'tinymce-rails'
require 'tinymce-rails-imageupload'

module Sufia
  extend ActiveSupport::Autoload

  eager_autoload do
    autoload :FormBuilder
  end

  class Engine < ::Rails::Engine
    engine_name 'sufia'

    # Breadcrumbs on rails must be required outside of an initializer or it doesn't get loaded.
    require 'breadcrumbs_on_rails'

    config.autoload_paths += %W(
      #{config.root}/app/controllers/concerns
      #{config.root}/app/helpers/concerns
      #{config.root}/app/models/concerns
      #{Hydra::Engine.root}/app/models/concerns
    )

    initializer 'sufia.assets.precompile' do |app|
      app.config.assets.paths << config.root.join('vendor', 'assets', 'fonts')
      app.config.assets.paths << config.root.join('app', 'assets', 'images')
      app.config.assets.paths << config.root.join('app', 'assets', 'images', 'blacklight')
      app.config.assets.paths << config.root.join('app', 'assets', 'images', 'hydra')
      app.config.assets.paths << config.root.join('app', 'assets', 'images', 'site_images')

      app.config.assets.precompile << /vjs\.(?:eot|ttf|woff)$/
      app.config.assets.precompile << /fontawesome-webfont\.(?:svg|ttf|woff)$/
      app.config.assets.precompile += %w( ZeroClipboard.swf )
      app.config.assets.precompile += %w(*.png *.jpg *.ico *.gif *.svg)
    end
  end
end
