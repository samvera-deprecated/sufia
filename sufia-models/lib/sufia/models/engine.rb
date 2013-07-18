require 'sufia/models/resque'
module Sufia
  module Models
    def self.config(&block)
      @@config ||= Engine::Configuration.new

      yield @@config if block

      return @@config
    end

    class Engine < ::Rails::Engine

      # Set some configuration defaults
      config.enable_ffmpeg = false
      config.noid_template = '.reeddeeddk'
      config.ffmpeg_path = 'ffmpeg'
      config.fits_message_length = 5
      config.temp_file_base = nil
      config.minter_statefile = '/tmp/minter-state'
      config.id_namespace = "sufia"
      config.fits_path = "fits.sh"
      config.enable_contact_form_delivery = false
      config.dropbox_api_key = nil
      config.queue = Sufia::Resque::Queue

      config.autoload_paths += %W(
        #{config.root}/lib/sufia/models/jobs
        #{config.root}/app/models/datastreams
      )

      rake_tasks do
        load File.expand_path('../../../tasks/sufia-models_tasks.rake', __FILE__)
      end

      initializer "patches" do
        require 'sufia/models/active_fedora/redis'
        require 'sufia/models/active_record/redis'
        require 'sufia/models/active_support/core_ext/marshal' unless Rails::VERSION::MAJOR == 4
      end

      initializer 'requires' do
        require 'sufia/models/model_methods'
        require 'sufia/models/noid'
        require 'sufia/models/file_content'
        require 'sufia/models/file_content/extract_metadata'
        require 'sufia/models/file_content/versions'
        require 'sufia/models/generic_file/actions'
        require 'sufia/models/generic_file/audit'
        require 'sufia/models/generic_file/characterization'
        require 'sufia/models/generic_file/export'
        require 'sufia/models/generic_file/permissions'
        require 'sufia/models/generic_file/thumbnail'
        require 'sufia/models/generic_file'
        require 'sufia/models/user'
        require 'sufia/models/id_service'
        require 'sufia/models/solr_document_behavior'
      end
    end
  end
end
