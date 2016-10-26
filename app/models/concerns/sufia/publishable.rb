module Sufia
  module Publishable
    extend CurationConcerns::Publishable

    def suppressed?
      state == inactive_uri
    end

    private

      def inactive_uri
        ::RDF::URI('http://fedora.info/definitions/1/0/access/ObjState#inactive')
      end
  end
end
