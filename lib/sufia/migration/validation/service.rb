module Sufia
  module Migration
    module Validation
      class Service
        attr_reader :model_mapping

        def initialize
          @model_mapping = { Collection: Collection, GenericFile: GenericWork }
        end

        def register(original_class, new_class)
          key = original_class.to_s.to_sym
          raise RuntimeError("New class registered must be an instance of a class #{new_class.class}") if new_class.class != Class
          @model_mapping[key] = new_class
          @model_mapping
        end

        def call
          Sufia::Migration::Survey::Item.all.each do |item|
            object = ActiveFedora::Base.where(id: item.object_id)
            item.migration_status = validate(item, object[0])
            item.save
          end
        end

        private

          def validate(item, object)
            return :missing if object.blank?
            return :wrong_type if object.class != model_mapping[item.object_class.to_sym]
            :successful
          end
      end
    end
  end
end
