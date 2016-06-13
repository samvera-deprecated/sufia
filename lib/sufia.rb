require 'select2-rails'
require 'nest'
require 'redis-namespace'
require 'mailboxer'
require 'acts_as_follower'
require 'carrierwave'
require "active_resource" # used by FileSet to catch errors & by GeoNamesResource
require 'rails_autolink'
require 'font-awesome-rails'
require 'tinymce-rails'
require 'tinymce-rails-imageupload'
require 'blacklight'
require 'blacklight_advanced_search'
require 'blacklight/gallery'
require 'active_fedora/noid'
require 'hydra/head'
require 'hydra-batch-edit'
require 'hydra-editor'
require 'browse-everything'
require 'curation_concerns'
require 'sufia/engine'
require 'sufia/version'
require 'sufia/inflections'
require 'kaminari_route_prefix'

module Sufia
  extend ActiveSupport::Autoload

  eager_autoload do
    autoload :Arkivo
    autoload :Configuration
    autoload :RedisEventStore
    autoload :Zotero
  end

  attr_writer :queue

  def self.queue
    @queue ||= config.queue.new('sufia')
  end

  def self.config(&block)
    @config ||= Sufia::Configuration.new

    yield @config if block

    @config
  end

  # This method is called once for each statement in the graph.
  def self.id_to_resource_uri
    lambda do |id, graph|
      result = graph.query([nil, ActiveFedora::RDF::Fcrepo::Model.hasModel, nil]).first
      route_key = result.object.to_s.constantize.model_name.singular_route_key
      routes = Rails.application.routes.url_helpers
      builder = ActionDispatch::Routing::PolymorphicRoutes::HelperMethodBuilder
      builder.polymorphic_method routes, route_key, nil, :url, id: id, host: hostname
    end
  end

  def self.hostname
    config.hostname
  end
end
