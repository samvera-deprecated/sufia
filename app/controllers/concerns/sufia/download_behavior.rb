# Extends CurationConcerns::DownloadBehavior to allow loading cached uploaded files
module Sufia
  module DownloadBehavior
    extend ActiveSupport::Concern
    include CurationConcerns::DownloadBehavior

    # Override to handle when file is a File
    def show
      return super unless file.is_a? File
      # For derivatives stored on the local filesystem
      response.headers['Accept-Ranges'] = 'bytes'
      response.headers['Content-Length'] = File.size(file).to_s
      send_file file, derivative_download_options
    end

    protected

      # If Fedora is down, load file from Sufia's cache of uploaded files
      def default_file
        super
      rescue Faraday::ConnectionFailed
        cached_uploaded_file
      end

    private

      # Grab the UploadedFile by the given id param, coerce to file
      def cached_uploaded_file
        Sufia::UploadedFile.find_by(file_set_uri: ActiveFedora::Base.id_to_uri(params[:id])).file.file.to_file
      end
  end
end
