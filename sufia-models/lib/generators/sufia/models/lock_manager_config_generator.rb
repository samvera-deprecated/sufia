require 'rails/generators'

class Sufia::Models::LockManagerConfigGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  desc """
This Generator makes the following changes to your application:
  1. Updates existing sufia.rb initializer to include lock manager configurations
       """

  def banner
    say_status("info", "ADDING LOCK MANAGER OPTION TO SUFIA CONFIG", :blue)
  end

  def inject_config_initializer
    inject_into_file 'config/initializers/sufia.rb', before: "# Where to store tempfiles, leave blank for the system temp directory (e.g. /tmp)" do
      "\n  # How many times to retry to acquire the lock before raising UnableToAcquireLockError\n" +
        "  # Default is 600ms\n" +
        "  # config.lock_retry_count = 600 # Up to 2 minutes of trying at intervals up to 200ms\n" +
        "\n  # How long to hold the lock in milliseconds\n" +
        "  # Default is 60_000ms\n" +
        "  # config.lock_time_to_live = 60_000 # milliseconds\n" +
        "\n  # Maximum wait time in milliseconds before retrying. Wait time is a random value between 0 and retry_delay.\n" +
        "  # Default is 200ms\n" +
        "  # config.lock_retry_delay = 200 # milliseconds\n\n"
    end
  end
end
