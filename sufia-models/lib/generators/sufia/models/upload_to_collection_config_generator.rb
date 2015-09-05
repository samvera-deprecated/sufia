require 'rails/generators'

class Sufia::Models::UploadToCollectionConfigGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  desc """
This Generator makes the following changes to your application:
  1. Updates existing sufia.rb initializer to include a update_to_collection configuration
       """

  def banner
    say_status("info", "ADDING UPLOAD_TO_COLLECTION OPTION TO SUFIA CONFIG", :blue)
  end

  def inject_config_initializer
    inject_into_file 'config/initializers/sufia.rb', before: "# Where to store tempfiles, leave blank for the system temp directory (e.g. /tmp)" do
      "# Enables a select menu on the batch upload page to select a collection into which to add newly uploaded files.\n" +
        "# Default is false\n" +
        "# config.upload_to_collection = false\n"
    end
  end
end
