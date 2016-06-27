module Sufia
  module Export
    # a base class to convert an ActiveFedora object that contains permissions and allow for pretty json.
    #
    class Converter
      # overrides to_json to optionally allow for a pretty version of the json to be outputted
      #
      # @param [Boolean] pretty pass true to output formatted json using pretty_generate
      def to_json(options = {})
        pretty = options.delete(:pretty)
        json = super
        return json unless pretty
        JSON.pretty_generate(JSON.parse(json))
      end

      private

        def permissions(object)
          object.permissions.map { |p| PermissionConverter.new(p) }
        end
    end
  end
end
