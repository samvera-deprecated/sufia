# -*- coding: utf-8 -*-
# Copyright © 2012 The Pennsylvania State University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module Sufia
  module FilesControllerBehavior
    extend ActiveSupport::Concern

    included do
      include Hydra::Controller::ControllerBehavior
      include Blacklight::Configurable # comply with BL 3.7
      include Sufia::Noid # for normalize_identifier method

      # This is needed as of BL 3.7
      self.copy_blacklight_config_from(CatalogController)

      # Catch permission errors
      rescue_from Hydra::AccessDenied, CanCan::AccessDenied do |exception|
        if (exception.action == :edit)
          redirect_to(sufia.url_for({:action=>'show'}), :alert => "You do not have sufficient privileges to edit this document")
        elsif current_user and current_user.persisted?
          redirect_to root_url, :alert => exception.message
        else
          session["user_return_to"] = request.url
          redirect_to new_user_session_url, :alert => exception.message
        end
      end

      # actions: audit, index, create, new, edit, show, update, destroy, permissions, citation
      before_filter :authenticate_user!, :except => [:show, :citation]
      before_filter :has_access?, :except => [:show]
      prepend_before_filter :normalize_identifier, :except => [:index, :create, :new]
      load_resource :only=>[:audit]
      load_and_authorize_resource :except=>[:index, :audit]
    end

    # routed to /files/new
    def new
      @generic_file = ::GenericFile.new
      @batch_noid = Sufia::Noid.noidify(Sufia::IdService.mint)
    end

    # routed to /files/:id/edit
    def edit
      @terms = @generic_file.terms_for_editing
      @groups = current_user.groups
    end

    # routed to /files/:id
    def index
      @generic_files = ::GenericFile.find(:all, :rows => ::GenericFile.count)
      render :json => @generic_files.map(&:to_jq_upload).to_json
    end

    # routed to /files/:id (DELETE)
    def destroy
      pid = @generic_file.noid
      @generic_file.delete
      Sufia.queue.push(ContentDeleteEventJob.new(pid, current_user.user_key))
      redirect_to sufia.dashboard_index_path, :notice => render_to_string(:partial=>'generic_files/asset_deleted_flash', :locals => { :generic_file => @generic_file })
    end

    # routed to /files (POST)
    def create
      begin
        retval = " "
        # check error condition No files
        return render(:json => [{:error => "Error! No file to save"}].to_json) if !params.has_key?(:files)

        file = params[:files].detect {|f| f.respond_to?(:original_filename) }
        if !file
          render :json => [{:name => 'unknown file', :error => "Error! No file for upload"}], :status => :unprocessable_entity
          return false
        end

        # check error condition empty file
        if ((file.respond_to?(:tempfile)) && (file.tempfile.size == 0))
           retval = render :json => [{ :name => file.original_filename, :error => "Error! Zero Length File!"}].to_json
        elsif ((file.respond_to?(:size)) && (file.size == 0))
           retval = render :json => [{ :name => file.original_filename, :error => "Error! Zero Length File!"}].to_json
        elsif (params[:terms_of_service] != '1')
           retval = render :json => [{ :name => file.original_filename, :error => "You must accept the terms of service!"}].to_json

        # process file
        else
          if virus_check(file) == 0 
            @generic_file = ::GenericFile.new
            # Relative path is set by the jquery uploader when uploading a directory
            @generic_file.relative_path = params[:relative_path] if params[:relative_path]
            Sufia::GenericFile::Actions.create_metadata(@generic_file, current_user, params[:batch_id])
            Sufia::GenericFile::Actions.create_content(@generic_file, file, file.original_filename, datastream_id, current_user)
            respond_to do |format|
              format.html {
                retval = render :json => [@generic_file.to_jq_upload].to_json,
                  :content_type => 'text/html',
                  :layout => false
              }
              format.json {
                retval = render :json => [@generic_file.to_jq_upload].to_json
              }
            end
          else
            retval = render :json => [{:error => "Error creating generic file."}].to_json
          end
        end
      rescue => error
        logger.error "GenericFilesController::create rescued #{error.class}\n\t#{error.to_s}\n #{error.backtrace.join("\n")}\n\n"
        retval = render :json => [{:error => "Error occurred while creating generic file."}].to_json
      ensure
        # remove the tempfile (only if it is a temp file)
        file.tempfile.delete if file.respond_to?(:tempfile)
      end

      return retval
    end

    # routed to /files/:id/citation
    def citation
    end

    # routed to /files/:id
    def show
      @can_edit =  can? :edit, @generic_file
      @events = @generic_file.events(100)

      respond_to do |format|
        format.html
        format.endnote { render :text => @generic_file.export_as_endnote }
      end
    end

    # routed to /files/:id/audit (POST)
    def audit
      render :json=>@generic_file.audit
    end

    # routed to /files/:id (PUT)
    def update
      version_event = false

      if params.has_key?(:revision) and params[:revision] !=  @generic_file.content.latest_version.versionID
        revision = @generic_file.content.get_version(params[:revision])
        @generic_file.add_file_datastream(revision.content, :dsid => 'content')
        version_event = true
        Sufia.queue.push(ContentRestoredVersionEventJob.new(@generic_file.pid, current_user.user_key, params[:revision]))
      end

      if params.has_key?(:filedata)
        file = params[:filedata]
        return unless virus_check(file) == 0
        @generic_file.add_file(file, datastream_id, file.original_filename)
        version_event = true
        Sufia.queue.push(ContentNewVersionEventJob.new(@generic_file.pid, current_user.user_key))
      end

      # only update metadata if there is a generic_file object which is not the case for version updates
      update_metadata if params[:generic_file]

      #always save the file so the new version or metadata gets recorded
      @generic_file.save!

      # do not trigger an update event if a version event has already been triggered
      Sufia.queue.push(ContentUpdateEventJob.new(@generic_file.pid, current_user.user_key)) unless version_event
      @generic_file.record_version_committer(current_user)
      redirect_to sufia.edit_generic_file_path(:tab => params[:redirect_tab]), :notice => render_to_string(:partial=>'generic_files/asset_updated_flash', :locals => { :generic_file => @generic_file })

    end

    protected

    # The name of the datastream where we store the file data
    def datastream_id
      'content'
    end

    # this is provided so that implementing application can override this behavior and map params to different attributes
    def update_metadata
      valid_attributes = params[:generic_file].select { |k,v| (@generic_file.terms_for_editing + [:permissions]).include? k.to_sym}
      @generic_file.attributes = valid_attributes
      @generic_file.set_visibility(params[:visibility])
      @generic_file.date_modified = DateTime.now
    end


    def virus_check( file)
      if defined? ClamAV
        stat = ClamAV.instance.scanfile(file.path)
        flash[:error] = "Virus checking did not pass for #{file.original_filename} status = #{stat}" unless stat == 0
        logger.warn "Virus checking did not pass for #{file.inspect} status = #{stat}" unless stat == 0
        stat
      else
        logger.warn "Virus checking disabled for #{file.inspect}"
        0
      end
    end 

  end
end
