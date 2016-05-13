module Sufia
  #
  # Generates CSV from a FileSet
  #
  # @attr_reader [FileSet] file_set file that will be examined to generate the CSVs
  # @attr_reader [Array] terms list of terms that will be output in CSV form
  # @attr_reader [String] multi_value_separator separator for terms that have more than one value
  class FileSetCSVService
    attr_reader :file_set, :terms, :multi_value_separator

    # @param [SolrDocument] file solr document that will be examined to generate the CSVs
    # @param [Array]        terms list of terms that will be output in CSV form
    #                       defaults if nil to list below
    # @param [String]       multi_value_separator separator for terms that have more than one value
    #                       defaults to '|'
    def initialize(file, terms = nil, multi_value_separator = '|')
      @file_set = file
      @terms = terms
      @terms ||= [:id, :title, :depositor, :creator, :visibility, :resource_type, :rights, :file_format]
      @multi_value_separator = multi_value_separator
    end

    # provide csv version of the FileSet
    def csv
      ::CSV.generate do |csv|
        csv << terms.map do |term|
          values = file_set.send(term)
          values = Array.wrap(values) # make sure we have an array
          values.join(multi_value_separator)
        end
      end
    end

    # provide csv header line for a FileSet
    def csv_header
      ::CSV.generate do |csv|
        csv << terms
      end
    end
  end
end
