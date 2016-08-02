module Sufia
  class Engine < ::Rails::Engine
    engine_name 'sufia'

    # These gems must be required outside of an initializer or it doesn't get loaded.
    require 'breadcrumbs_on_rails'
    require 'jquery-ui-rails'
    require 'flot-rails'
    require 'almond-rails'
    require 'zeroclipboard-rails'

    config.autoload_paths += %W(
      #{config.root}/app/controllers/concerns
      #{config.root}/app/models/concerns
      #{Hydra::Engine.root}/app/models/concerns
    )

    rake_tasks do
      load File.expand_path('../../../tasks/noid.rake', __FILE__)
      load File.expand_path('../../../tasks/reindex.rake', __FILE__)
      load File.expand_path('../../../tasks/stats_tasks.rake', __FILE__)
      load File.expand_path('../../../tasks/sufia_user.rake', __FILE__)
    end

    initializer 'requires' do
      require 'hydra/derivatives'
    end

    initializer 'configure' do
      Sufia.config.tap do |c|
        Hydra::Derivatives.ffmpeg_path    = c.ffmpeg_path
        Hydra::Derivatives.temp_file_base = c.temp_file_base
        Hydra::Derivatives.fits_path      = c.fits_path
        Hydra::Derivatives.enable_ffmpeg  = c.enable_ffmpeg
        Hydra::Derivatives.libreoffice_path = c.libreoffice_path

        # TODO: Remove when https://github.com/projecthydra/curation_concerns/pull/848 is merged
        ActiveFedora::Base.translate_uri_to_id = c.translate_uri_to_id
        ActiveFedora::Base.translate_id_to_uri = c.translate_id_to_uri
        ActiveFedora::Noid.config.template = c.noid_template
        ActiveFedora::Noid.config.statefile = c.minter_statefile
      end

      CurationConcerns::CurationConcern.actor_factory = Sufia::ActorFactory
    end

    initializer 'sufia.assets.precompile' do |app|
      app.config.assets.paths << config.root.join('vendor', 'assets', 'fonts')
      app.config.assets.paths << config.root.join('app', 'assets', 'images')
      app.config.assets.paths << config.root.join('app', 'assets', 'images', 'blacklight')
      app.config.assets.paths << config.root.join('app', 'assets', 'images', 'hydra')
      app.config.assets.paths << config.root.join('app', 'assets', 'images', 'site_images')

      app.config.assets.precompile << /fontawesome-webfont\.(?:svg|ttf|woff)$/
      app.config.assets.precompile += %w( ZeroClipboard.swf )
      app.config.assets.precompile += %w(*.png *.jpg *.ico *.gif *.svg)

      Sprockets::ES6.configuration = { 'modules' => 'amd', 'moduleIds' => true }
      # When we upgrade to Sprockets 4, we can ditch sprockets-es6 and config AMD
      # in this way:
      # https://github.com/rails/sprockets/issues/73#issuecomment-139113466
    end
  end
end
