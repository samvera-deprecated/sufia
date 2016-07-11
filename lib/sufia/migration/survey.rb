require 'sufia/migration/survey/item'
require 'sufia/migration/survey/fedora_id_service'
require 'sufia/migration/survey/surveyor'

module Sufia
  module Migration
    module Survey
      VERSION = Sufia::VERSION

      def self.table_name_prefix
        'sufia_migration_survey_'
      end
    end
  end
end
