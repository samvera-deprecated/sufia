module Sufia
  module Import
    # An abstract class to Build an object
    #
    class Builder
      attr_reader :settings, :import_binary, :sufia6_user, :sufia6_password

      # @param Hash settings
      #        @attr sufia6_user      - User name for accessing the sufia 6 fedora
      #        @attr sufia6_password  - Password for accessing the sufia 6 fedora
      #        @attr import_binary    - (default true) Import the binaryt content from fedora
      def initialize(settings)
        @settings = settings
        @import_binary = settings.fetch(:import_binary, true)
        @sufia6_user = settings[:sufia6_user]
        @sufia6_password = settings[:sufia6_password]
      end

      def build(_generic_file_metadata)
        raise "need to override"
      end
    end
  end
end
