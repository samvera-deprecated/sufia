class PagesController < ApplicationController

  def show
    @page = Page.find_by_name(params[:id])
  end


  def create
    params[:content].each do |page_name, opts|
      page = Page.find_or_initialize_by(name: page_name)
      authorize! :update, page
      page.value = opts[:value]
      page.save!
    end
    respond_to do |format| 
      format.json { render json: true}
    end
  end
end
