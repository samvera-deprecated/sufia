require 'sufia/single_use_error'

class SingleUseLinkController < DownloadsController
  before_filter :authenticate_user!, :except => [:download, :show]
  before_filter :find_file, :only => [:generate_download, :generate_show]
  before_filter :authorize_user!, :only => [:generate_download, :generate_show]
  skip_filter :normalize_identifier, :load_asset, :load_datastream
  prepend_before_filter :normalize_identifier, :except => [:download, :show]
  rescue_from Sufia::SingleUseError, :with => :render_single_use_error

  def generate_download
    @su =  SingleUseLink.create_download(params[:id])
    @link =  sufia.download_single_use_link_path(@su.downloadKey)
    respond_to do |format|
      format.html
      format.js  {render :js => @link}
    end
  end

  def generate_show
    @su = SingleUseLink.create_show(params[:id])
    @link = sufia.show_single_use_link_path(@su.downloadKey)
    respond_to do |format|
      format.html
      format.js  {render :js => @link}
    end
  end

  def download
    #look up the item
    link = lookup_hash

    #grab the item id
    id = link.itemId

    #check to make sure the path matches
    not_found if link.path != sufia.download_path(id)

    # send the data content
    @asset = GenericFile.load_instance_from_solr(id)
    load_datastream
    send_content(asset)
  end

  def show
    link = lookup_hash

    #grab the item id
    id = link.itemId

    #check to make sure the path matches
    not_found if link.path != sufia.generic_file_path(id)

    #show the file
    @generic_file = GenericFile.load_instance_from_solr(id)
    @terms = @generic_file.terms_for_display

    # create a dowload link that is single use for the user since we do not just want to show metadata we want to access it too
    @su =  SingleUseLink.create_download(id)
    @download_link =  sufia.download_single_use_link_path(@su.downloadKey)
  end

  protected

  def authorize_user!
    authorize! :read, @generic_file
  end

  def find_file
    @generic_file = GenericFile.load_instance_from_solr(params[:id])
  end

  def lookup_hash
    id = params[:id]
    # invalid hash send not found
    link = SingleUseLink.where(downloadKey:id).first || not_found

    # expired hash send not found
    now = DateTime.now
    not_found if link.expires <= now

    # delete the link since it has been used
    link.destroy

    return link
  end

  def not_found
    raise Sufia::SingleUseError.new('Single-Use Link Not Found')
  end

  def expired
    raise Sufia::SingleUseError.new('Single-Use Link Expired')
  end
end
