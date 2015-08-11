require 'spec_helper'

describe 'single_use_links_viewer/show.html.erb' do
  let(:user) { FactoryGirl.find_or_create(:jill) }
  let(:file) do
    GenericFile.create do |f|
      f.add_file(File.open(fixture_path + '/world.png'), path: 'content', original_name: 'world.png')
      f.label = 'world.png'
      f.apply_depositor_metadata(user)
    end
  end

  let(:hash) { "some-dummy-sha2-hash" }

  before do
    assign :asset, file
    assign :download_link, Sufia::Engine.routes.url_helpers.download_single_use_link_path(hash)
    assign :presenter, Sufia::GenericFilePresenter.new(file)
    render
  end

  it "contains a download link" do
    expect(rendered).to have_selector "a[href^='/single_use_link/download/']"
  end

  it "has turbolinks disabled in the download link" do
    expect(rendered).to have_selector "a[data-no-turbolink][href^='/single_use_link/download/']"
  end
end
