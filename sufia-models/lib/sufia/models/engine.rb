module Sufia
  module Models
    def self.config(&block)
      @@config ||= Engine::Configuration.new

      yield @@config if block

      return @@config
    end

    class Engine < ::Rails::Engine
      require 'sufia/models/resque'

      # Set some configuration defaults
      config.persistent_hostpath = "http://localhost/files/"
      config.enable_ffmpeg = false
      config.noid_template = '.reeddeeddk'
      config.ffmpeg_path = 'ffmpeg'
      config.fits_message_length = 5
      config.temp_file_base = nil
      config.minter_statefile = '/tmp/minter-state'
      config.id_namespace = "sufia"
      config.fits_path = "fits.sh"
      config.enable_contact_form_delivery = false
      config.browse_everything = nil
      config.enable_local_ingest = nil
      config.analytics = false
      config.queue = Sufia::Resque::Queue
      config.max_notifications_for_dashboard = 5
      config.activity_to_show_default_seconds_since_now = 24*60*60

      # Defaulting analytic start date to when ever the file was uploaded by leaving it blank
      config.analytic_start_date = nil

      config.translate_uri_to_id = lambda { |uri| uri.to_s.split('/')[-1] }
      config.translate_id_to_uri = lambda { |id|
        "#{ActiveFedora.fedora.host}#{ActiveFedora.fedora.base_path}/#{Sufia::Noid.treeify(id)}" }

      config.autoload_paths += %W(
        #{config.root}/app/models/datastreams
      )

      rake_tasks do
        load File.expand_path('../../../tasks/sufia-models_tasks.rake', __FILE__)
      end

      initializer "patches" do
        require 'sufia/models/active_fedora/redis'
        require 'sufia/models/active_record/redis'
      end

      initializer 'requires' do
        require 'activerecord-import'
        require 'hydra/derivatives'
        require 'sufia/models/file_content'
        require 'sufia/models/file_content/versions'
        require 'sufia/models/user_local_directory_behavior'
        require 'sufia/noid'
        require 'sufia/id_service'
        require 'sufia/analytics'
        require 'sufia/pageview'
        require 'sufia/download'
      end

      initializer 'configure' do
        Sufia.config.tap do |c|
          Hydra::Derivatives.ffmpeg_path    = c.ffmpeg_path
          Hydra::Derivatives.temp_file_base = c.temp_file_base
          Hydra::Derivatives.fits_path      = c.fits_path
          Hydra::Derivatives.enable_ffmpeg  = c.enable_ffmpeg

          ActiveFedora::Base.translate_uri_to_id = c.translate_uri_to_id
          ActiveFedora::Base.translate_id_to_uri = c.translate_id_to_uri
        end
      end
    end
  end
end
