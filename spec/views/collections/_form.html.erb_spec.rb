require 'spec_helper'

describe 'collections/_form.html.erb' do
  let(:user1) { FactoryGirl.create(:user) }
  let(:collection) { create(:public_collection, title: "the title", creator: ["the creator"], description: "the description", user: user1) }
  let(:collection_form) { Sufia::Forms::CollectionEditForm.new(collection) }

  before do
    allow(controller).to receive(:current_user).and_return(user1)
    controller.request.path_parameters[:id] = 'j12345'
    assign(:form, collection_form)
  end

  it "draws the metadata fields for collection" do
    render
    expect(rendered).to have_selector("input#collection_title")
    expect(rendered).to_not have_selector("div#additional_title.multi_value")
    expect(rendered).to have_selector("input#collection_creator.multi_value")
    expect(rendered).to have_selector("textarea#collection_description")
    expect(rendered).to have_selector("input#collection_contributor")
    expect(rendered).to have_selector("input#collection_tag")
    expect(rendered).to have_selector("input#collection_subject")
    expect(rendered).to have_selector("input#collection_publisher")
    expect(rendered).to have_selector("input#collection_date_created")
    expect(rendered).to have_selector("input#collection_language")
    expect(rendered).to have_selector("input#collection_identifier")
    expect(rendered).to have_selector("input#collection_based_near")
    expect(rendered).to have_selector("input#collection_related_url")
    expect(rendered).to have_selector("select#collection_rights")
    expect(rendered).to have_selector("select#collection_resource_type")
    expect(rendered).to have_selector("input#visibility_open")
    expect(rendered).to have_selector("input#visibility_psu")
    expect(rendered).to have_selector("input#visibility_restricted")
  end
end
