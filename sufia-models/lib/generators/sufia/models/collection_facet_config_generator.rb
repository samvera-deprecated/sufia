require 'rails/generators'

class Sufia::Models::CollectionFacetConfigGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  desc """
This Generator makes the following changes to your application:
  1. Updates existing sufia.rb initializer to include a collection_facet configuration
       """

  def banner
    say_status("info", "ADDING COLLECTION_FACET OPTION TO SUFIA CONFIG", :blue)
  end

  def inject_config_initializer
    inject_into_file 'config/initializers/sufia.rb', before: "# Where to store tempfiles, leave blank for the system temp directory (e.g. /tmp)" do
      "  # Add a collection facet to search results.  Possible values are...\n" +
        "  #   nil (default) - do not include collection facet\n" +
        "  #   :user - show for logged in users\n" +
        "  #   :public - show for everyone (e.g. logged in and non-logged in users)\n" +
        "  config.collection_facet = nil\n" +
        "  # config.collection_facet = :user\n" +
        "  # config.collection_facet = :public\n"
    end
  end
end
