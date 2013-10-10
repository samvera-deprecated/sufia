# Responsible for extracting characterization metadata
# from the given object.
#
# This is not in a complete state, but instead reflects a step towards
# extraction.
class CharacterizationService
  attr_reader :object, :terminology, :fits_to_desc_mapping
  def initialize(object, config = {})
    @object = object
    @fits_to_desc_mapping = config.fetch(:fits_to_desc_mapping, Sufia.config.fits_to_desc_mapping)
    @terminology = config.fetch(:terminology, object.characterization.class.terminology)
  end

  def call
    object.characterization.ng_xml = object.content.extract_metadata
    append_metadata
    object.filename = object.label
    object.save
  end

  protected

  # Populate descMetadata with fields from FITS (e.g. Author from pdfs)
  def append_metadata
    terms = object.characterization_terms
    fits_to_desc_mapping.each_pair do |k, v|
      if terms.has_key?(k)
        # coerce to array to remove a conditional
        terms[k] = [terms[k]] unless terms[k].is_a? Array
        terms[k].each do |term_value|
          proxy_term = object.send(v)
          if proxy_term.kind_of?(Array)
            proxy_term << term_value unless proxy_term.include?(term_value)
          else
            # these are single-valued terms which cannot be appended to
            object.send("#{v}=", term_value)
          end
        end
      end
    end
  end

end