require 'sufia/single_use_error'

class SingleUseLinksViewerController < ApplicationController

  include Sufia::DownloadsControllerBehavior

  skip_filter :normalize_identifier
  skip_before_filter :load_datastream, :except => :download

  before_filter :authorize_single_use_link!

  class Ability
    include CanCan::Ability

    attr_reader :single_use_link

    def initialize(user, single_use_link)
      @user = user || User.new

      @single_use_link = single_use_link

      can :read, ActiveFedora::Base do |obj|
        single_use_link.valid? and
          single_use_link.itemId == obj.pid and single_use_link.destroy!
      end if single_use_link

    end
  end

  rescue_from Sufia::SingleUseError, :with => :render_single_use_error
  rescue_from CanCan::AccessDenied, :with => :render_single_use_error
  rescue_from ActiveRecord::RecordNotFound, :with => :render_single_use_error


  def download
    # send the data content
    raise not_found_exception unless single_use_link.path == sufia.download_path(:id => @asset)
    send_content(asset)
  end

  def show
    raise not_found_exception unless single_use_link.path == sufia.polymorphic_path(@asset)

    #show the file
    @terms = @asset.terms_for_display

    # create a dowload link that is single use for the user since we do not just want to show metadata we want to access it too
    @su = single_use_link.create_for_path sufia.download_path(:id => @asset)
    @download_link = sufia.download_single_use_link_path(@su.downloadKey)
  end

  protected

  def authorize_single_use_link!
    authorize! :read, @asset
  end

  def single_use_link
    @single_use_link ||= SingleUseLink.find_by_downloadKey! params[:id]
  end

  def not_found_exception
    Sufia::SingleUseError.new('Single-Use Link Not Found')
  end

  def load_asset
    @asset = ActiveFedora::Base.load_instance_from_solr(single_use_link.itemId)
  end

  def current_ability
    @current_ability ||= SingleUseLinksViewerController::Ability.new current_user, single_use_link
  end
end
