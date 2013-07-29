require "sufia/version"
require 'blacklight'
require 'blacklight_advanced_search'
require 'hydra/head'
require 'hydra-batch-edit'


require 'rails_autolink'

module Sufia
  extend ActiveSupport::Autoload

  class Engine < ::Rails::Engine
    engine_name 'sufia'

    config.autoload_paths += %W(
      #{config.root}/app/controllers/concerns
      #{config.root}/app/models/concerns
      #{config.root}/app/models/datastreams
      #{Hydra::Engine.root}/app/models/concerns
    )

    initializer 'sufia.initializer' do
      require 'sufia/models'
    end
  end

  autoload :Controller
  autoload :HttpHeaderAuth
  autoload :FilesControllerBehavior
  autoload :BatchEditsControllerBehavior
  autoload :DownloadsControllerBehavior
end
