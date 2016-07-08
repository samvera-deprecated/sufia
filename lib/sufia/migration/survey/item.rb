# ActiveRecord class to store the current migration status of an object in ActiveFedora.
#
# @attr [String] object_id fedora id of the object being migrated
# @attr [String] object_class fedora class of the object being migrated (Collection, GenericFile)
# @attr [String] object_title title of the object being migrated
# @attr [int]    migration_status - Status of the object's migration
# @option migration_status -1 initial state before migration
# @option migration_status 0 migrated successfully
# @option migration_status 1 Missing when verified
# @option migration_status 2 Migrated but wrong type
module Sufia
  module Migration
    module Survey
      class Item < ActiveRecord::Base
      end
    end
  end
end
