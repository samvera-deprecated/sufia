module Sufia
  class Statefile
    def self.default
      return '/tmp/minter-state' if Rails.env.development? || Rails.env.test?
      raise NotImplementedError, "can't use the default statefile for production" unless Dir.exist?('/var/sufia')
      '/var/sufia/minter-state'
    end
  end

  class Engine < ::Rails::Engine
    engine_name 'sufia'

    # Breadcrumbs on rails must be required outside of an initializer or it doesn't get loaded.
    require 'breadcrumbs_on_rails'

    config.autoload_paths += %W(
      #{config.root}/app/controllers/concerns
      #{config.root}/app/models/concerns
      #{Hydra::Engine.root}/app/models/concerns
    )

    # Force these models to be added to Legato's registry in development mode
    config.eager_load_paths += %W(
      #{config.root}/app/models/sufia/download.rb
      #{config.root}/app/models/sufia/pageview.rb
    )

    rake_tasks do
      load File.expand_path('../../../tasks/noid.rake', __FILE__)
      load File.expand_path('../../../tasks/reindex.rake', __FILE__)
      load File.expand_path('../../../tasks/resque.rake', __FILE__)
      load File.expand_path('../../../tasks/stats_tasks.rake', __FILE__)
      load File.expand_path('../../../tasks/sufia_user.rake', __FILE__)
      load File.expand_path('../../../tasks/upload_set_cleanup.rake', __FILE__)
    end

    initializer 'requires' do
      require 'activerecord-import'
      require 'hydra/derivatives'
    end

    initializer 'configure' do
      Sufia.config.tap do |c|
        Hydra::Derivatives.ffmpeg_path    = c.ffmpeg_path
        Hydra::Derivatives.temp_file_base = c.temp_file_base
        Hydra::Derivatives.fits_path      = c.fits_path
        Hydra::Derivatives.enable_ffmpeg  = c.enable_ffmpeg

        ActiveFedora::Base.translate_uri_to_id = c.translate_uri_to_id
        ActiveFedora::Base.translate_id_to_uri = c.translate_id_to_uri
        ActiveFedora::Noid.config.template = c.noid_template
        ActiveFedora::Noid.config.statefile = c.minter_statefile
      end
    end

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

    # Set some configuration defaults
    config.persistent_hostpath = "http://localhost/files/"
    config.enable_ffmpeg = false
    config.ffmpeg_path = 'ffmpeg'
    config.fits_message_length = 5
    config.temp_file_base = nil
    config.redis_namespace = "sufia"
    config.fits_path = "fits.sh"
    config.enable_contact_form_delivery = false
    config.browse_everything = nil
    config.enable_local_ingest = nil
    config.analytics = false
    config.citations = false
    config.max_notifications_for_dashboard = 5
    config.activity_to_show_default_seconds_since_now = 24 * 60 * 60
    config.arkivo_api = false
    config.geonames_username = ""

    # Noid identifiers
    config.enable_noids = true
    config.noid_template = '.reeddeeddk'
    config.minter_statefile = Statefile.default
    config.translate_uri_to_id = ActiveFedora::Noid.config.translate_uri_to_id
    config.translate_id_to_uri = ActiveFedora::Noid.config.translate_id_to_uri

    # Defaulting analytic start date to whenever the file was uploaded by leaving it blank
    config.analytic_start_date = nil
  end
end
