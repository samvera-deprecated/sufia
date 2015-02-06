class CreateDerivativesJob < ActiveFedoraPidBasedJob
  def queue_name
    :derivatives
  end

  def run
    return unless generic_file.content.has_content?
    if generic_file.video?
      return unless Sufia.config.enable_ffmpeg
    end
    status = Timeout::timeout(Sufia.config.derivatives_timeout) do
      generic_file.create_derivatives
    end
    generic_file.save
  rescue Timeout::Error => ex
    raise Hydra::Derivatives::TimeoutError, "Unable to generate derivatives for \"#{generic_file.id}\"\nThe derivatives generation took longer than #{Sufia.config.derivatives_timeout} seconds to execute"
  end
end
