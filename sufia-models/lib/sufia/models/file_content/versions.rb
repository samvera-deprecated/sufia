module Sufia
  module FileContent
    module Versions

      def latest_version
        versions.last unless versions.empty?
      end

      def save
        super.tap do |passing|
          create_version if passing
        end
      end
    end
  end
end
