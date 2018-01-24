# Workaround to accidental backwards breaking change in hydra-derivatives 7.4,
# removing a method that should have only been deprecated.
# https://github.com/samvera/hydra-derivatives/issues/181

hydra_derivatives_gem = Gem.loaded_specs["hydra-derivatives"]
if hydra_derivatives_gem &&
   (hydra_derivatives_gem.version.release >= Gem::Version.new('3.4.0')) &&
   (hydra_derivatives_gem.version.release < Gem::Version.new('3.5')) &&
   !Hydra::Derivatives::IoDecorator.instance_methods.include?(:original_name=)

  # rubocop:disable Alias
  Hydra::Derivatives::IoDecorator.class_eval do
    alias original_name= original_filename=
    deprecation_deprecate :"original_name=" => 'original_name= has been deprecated. Use original_filename= instead. This will be removed in hydra-derivatives 4.0'
  end
  # rubocop:enable Alias
end
