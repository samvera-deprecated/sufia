class ResolrizeGenericFileJob < ActiveFedoraIdBasedJob
  def queue_name
    :resolrize_generic_file
  end

  def run
    generic_file.update_index
  end
end
