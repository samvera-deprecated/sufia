# ActiveRecord class to store the current migration status of an object in ActiveFedora.
#
# @attr [String] object_id fedora id of the object being migrated
# @attr [String] object_class fedora class of the object being migrated (Collection, GenericFile)
# @attr [String] object_title title of the object being migrated
# @attr [enum]   migration_status - Status of the object's migration
# @option migration_status :initial_state initial state before migration
# @option migration_status :successful migrated successfully
# @option migration_status :missing Missing when verified
# @option migration_status :wrong_type Migrated but wrong type
module Sufia
  module Migration
    module Survey
      class Item < ActiveRecord::Base
        enum migration_status: [:initial_state, :successful, :missing, :wrong_type]
      end
    end
  end
end
