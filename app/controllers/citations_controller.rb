class CitationsController < ApplicationController
  include CurationConcerns::CurationConcernController
  include Sufia::Breadcrumbs
  include Sufia::SingularSubresourceController

  before_action :build_breadcrumbs, only: [:work, :file]

  def work
    @curation_concern_type = Work
    @presenter_class = Sufia::WorkShowPresenter
    show
  end

  def file
    @curation_concern_type = FileSet
    @presenter_class = Sufia::FileSetPresenter
    show
  end

  protected

    def show_presenter
      @presenter_class
    end
end
