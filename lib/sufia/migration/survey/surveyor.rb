# Class that will survey Fedora based on a list of ids
module Sufia
  module Migration
    module Survey
      class Surveyor
        class << self
          # call causes the surveyor to create a survey item for each id in the list
          #
          # @param [Array] id_list a list of ids to be surveyed
          def call(id_list)
            ActiveFedora::Base.find(id_list).each do |object|
              Item.find_or_create_by(object_id: object.id) do |item|
                item.assign_attributes(object_class: object.class, object_title: object.title, migration_status: :initial_state)
              end
            end
          end
        end
      end
    end
  end
end
