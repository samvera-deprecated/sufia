# Basic metadata for all Works
# Required fields:
#   dc:title
#   dc:rights
#
# Optional fields:
#   dc:contributor
#   dc:coverage
#   dc:creator
#   dc:date
#   dc:description
#   dc:format
#   dc:identifier
#   dc:language
#   dc:publisher
#   dc:relation
#   dc:source
#   dc:subject
#   dc:type
module Sufia::Works
  module CurationConcern
    module WithBasicMetadata
      extend ActiveSupport::Concern

      included do
        include GenericWorkRdfProperties
        # Validations that apply to all types of Work AND Collections
        validates_presence_of :title,  message: 'Your work must have a title.'


      end

    end
  end
end
