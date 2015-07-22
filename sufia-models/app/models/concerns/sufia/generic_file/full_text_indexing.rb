module Sufia
  module GenericFile
    module FullTextIndexing
      extend ActiveSupport::Concern

      included do
        contains 'full_text'
      end

      def append_metadata
        super
        extract_content
      end

      private

        def extract_content
          uri = URI("#{connection_url}/update/extract?extractOnly=true&wt=json&extractFormat=text")
          req = Net::HTTP.new(uri.host, uri.port)
          resp = req.post(uri.to_s, content.content,             'Content-type' => "#{mime_type};charset=utf-8",
                                                                 'Content-Length' => content.content.size.to_s)
          raise "URL '#{uri}' returned code #{resp.code}" unless resp.code == "200"
          content.content.rewind if content.content.respond_to?(:rewind)
          extracted_text = JSON.parse(resp.body)[''].rstrip
          full_text.content = extracted_text if extracted_text.present?
        rescue => e
          logger.error("Error extracting content from #{id}: #{e.inspect}")
        end

        def connection_url
          case
          when Blacklight.connection_config[:url] then Blacklight.connection_config[:url]
          when Blacklight.connection_config["url"] then Blacklight.connection_config["url"]
          when Blacklight.connection_config[:fulltext] then Blacklight.connection_config[:fulltext]["url"]
          else Blacklight.connection_config[:default]["url"]
          end
        end
    end
  end
end
