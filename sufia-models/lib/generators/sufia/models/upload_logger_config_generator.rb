require 'rails/generators'

class Sufia::Models::UploadLoggerConfigGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  desc """
This Generator makes the following changes to your application:
  1. Updates existing sufia.rb initializer to include a update_logger configuration
       """

  def banner
    say_status("info", "ADDING UPLOAD_LOGGER OPTION TO SUFIA CONFIG", :blue)
  end

  def inject_config_initializer
    inject_into_file 'config/initializers/sufia.rb', before: "# Where to store tempfiles, leave blank for the system temp directory (e.g. /tmp)" do
      "  # Specify file for logging upload file errors.\n" +
        "  config.upload_logger = Logger.new('log/upload_error.log')\n"
    end
  end
end
