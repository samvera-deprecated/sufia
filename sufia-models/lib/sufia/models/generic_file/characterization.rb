module Sufia
  module GenericFile
    module Characterization
      extend ActiveSupport::Concern
      included do
        has_metadata :name => "characterization", :type => FitsDatastream
        delegate :mime_type, :to => :characterization, multiple: false
        delegate_to :characterization, [:format_label, :file_size, :last_modified,
                                        :filename, :original_checksum, :rights_basis,
                                        :copyright_basis, :copyright_note,
                                        :well_formed, :valid, :status_message,
                                        :file_title, :file_author, :page_count,
                                        :file_language, :word_count, :character_count,
                                        :paragraph_count, :line_count, :table_count,
                                        :graphics_count, :byte_order, :compression,
                                        :width, :height, :color_space, :profile_name,
                                        :profile_version, :orientation, :color_map,
                                        :image_producer, :capture_device,
                                        :scanning_software, :exif_version,
                                        :gps_timestamp, :latitude, :longitude,
                                        :character_set, :markup_basis,
                                        :markup_language, :duration, :bit_depth,
                                        :sample_rate, :channels, :data_format, :offset], multiple: true

      end

      def characterize_if_changed
        content_changed = self.content.changed?
        yield
        #logger.debug "DOING CHARACTERIZE ON #{self.pid}"
        Sufia.queue.push(CharacterizeJob.new(self.pid)) if content_changed
      end

      ## Extract the metadata from the content datastream and record it in the characterization datastream
      def characterize
        characterization_service.call
      end

      def characterization_terms
        h = {}
        characterization.class.terminology.terms.each_pair do |k, v|
          next unless v.respond_to? :proxied_term
          term = v.proxied_term
          begin
            value = object.send(term.name)
            h[term.name] = value unless value.empty?
          rescue NoMethodError
            next
          end
        end
        h
      end

      attr_writer :characterization_service
      private
      def characterization_service
        @characterization_service ||= CharacterizationService.new(self)
      end
    end
  end
end