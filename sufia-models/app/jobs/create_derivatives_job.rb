class CreateDerivativesJob < ActiveFedoraIdBasedJob
  def queue_name
    :derivatives
  end

  def run
    return unless generic_file.content.has_content?
    return if generic_file.video? && !Sufia.config.enable_ffmpeg

    generic_file.create_derivatives
    generic_file.save
  end
end
