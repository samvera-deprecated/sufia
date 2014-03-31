require "sufia/version"
require 'blacklight'
require 'blacklight_advanced_search'
require 'hydra/head'
require 'hydra-batch-edit'
require 'sufia/models'

require 'rails_autolink'
require 'sass'
require 'font-awesome-sass-rails'

module Sufia
  extend ActiveSupport::Autoload

  class << self
    def load!
      ::Sass.load_paths << stylesheets_path
    end

    # Paths
    def gem_path
      @gem_path ||= File.expand_path '..', File.dirname(__FILE__)
    end

    def stylesheets_path
      File.join assets_path, 'stylesheets'
    end

    def assets_path
      @assets_path ||= File.join gem_path, 'vendor', 'assets'
    end
  end

  class Engine < ::Rails::Engine
    engine_name 'sufia'

    config.autoload_paths += %W(
      #{config.root}/app/controllers/concerns
      #{config.root}/app/models/concerns
      #{config.root}/app/models/datastreams
      #{Hydra::Engine.root}/app/models/concerns
    )

    config.assets.paths << config.root.join('vendor', 'assets', 'fonts')
    
  end

  autoload :Controller
  autoload :HttpHeaderAuth
  autoload :FilesControllerBehavior
  autoload :BatchEditsControllerBehavior
  autoload :DownloadsControllerBehavior
end

Sufia.load!
