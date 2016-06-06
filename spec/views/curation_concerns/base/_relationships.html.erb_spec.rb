require 'spec_helper'

describe 'curation_concerns/base/relationships', type: :view do
  let(:ability) { double }
  let(:solr_doc) { double(id: '123', human_readable_type: 'Work') }
  let(:presenter) { Sufia::WorkShowPresenter.new(solr_doc, ability) }
  let(:model_gw) { double("genericwork") }
  let(:model_col) { double("collection") }
  let(:collection) { double(id: '345', title: ['Containing collection', 'foobar'], to_s: 'Containing collection', model_name: model_col.model_name) }
  let(:generic_work) { double(id: '456', title: ['Containing work', 'barbaz'], to_s: 'Containing work', model_name: model_gw.model_name) }

  context "when collections are not present" do
    before do
      render 'curation_concerns/base/relationships', presenter: presenter
    end
    it "shows the message" do
      expect(rendered).to match %r{This Work is not currently in any collections\.}
    end
  end

  context "when children are not present" do
    before do
      render 'curation_concerns/base/relationships', presenter: presenter
    end
    it "shows the message" do
      expect(rendered).to match %r{This Work does not have any related works\.}
    end
  end

  context "when parents are not present" do
    before do
      render 'curation_concerns/base/relationships', presenter: presenter
    end
    it "shows the message" do
      expect(rendered).to match %r{This Work is not currently a part of any works\.}
    end
  end

  context "when collections are present and no parents are present" do
    let(:collection_presenters) { [collection] }
    let(:page) { Capybara::Node::Simple.new(rendered) }
    before do
      allow(view).to receive(:contextual_path).and_return("/collections/456")
      allow(model_col).to receive(:model_name).and_return("Collection")
      allow(presenter).to receive(:collection_presenters).and_return(collection_presenters)
      render 'curation_concerns/base/relationships', presenter: presenter
    end
    it "links to collections" do
      expect(page).to have_link 'Containing collection'
    end
    it "labels the link using the presenter's #to_s method" do
      expect(page).not_to have_content 'foobar'
    end
    it "should show the empty messages for parents" do
      expect(page).to_not have_content "This Work is not currently in any collections."
      expect(page).to have_content "This Work is not currently a part of any works."
    end
  end

  context "when parents are present and no collections are present" do
    let(:collection_presenters) { [generic_work] }
    let(:page) { Capybara::Node::Simple.new(rendered) }
    before do
      allow(view).to receive(:contextual_path).and_return("/concern/generic_works/456")
      allow(model_gw).to receive(:model_name).and_return("GenericWork")
      allow(presenter).to receive(:collection_presenters).and_return(collection_presenters)
      render 'curation_concerns/base/relationships', presenter: presenter
    end
    it "links to work" do
      expect(page).to have_link 'Containing work'
    end
    it "labels the link using the presenter's #to_s method" do
      expect(page).not_to have_content 'barbaz'
    end
    it "should show the empty messages for collections" do
      expect(page).to have_content "This Work is not currently in any collections."
      expect(page).to_not have_content "This Work is not currently a part of any works."
    end
  end

  context "when parents are present and collections are present" do
    let(:collection_presenters) { [generic_work, collection] }
    let(:page) { Capybara::Node::Simple.new(rendered) }
    before do
      allow(view).to receive(:contextual_path).and_return("/concern/generic_works/456")
      allow(model_gw).to receive(:model_name).and_return("GenericWork")
      allow(model_col).to receive(:model_name).and_return("Collection")
      allow(presenter).to receive(:collection_presenters).and_return(collection_presenters)
      render 'curation_concerns/base/relationships', presenter: presenter
    end
    it "links to work and collection" do
      expect(page).to have_link 'Containing work'
      expect(page).to have_link 'Containing collection'
    end
    it "labels the link using the presenter's #to_s method" do
      expect(page).not_to have_content 'barbaz'
      expect(page).not_to have_content 'foobar'
    end
    it "should not show the empty messages" do
      expect(page).to_not have_content "This Work is not currently in any collections."
      expect(page).to_not have_content "This Work is not currently a part of any works."
    end
  end

  context "when children are present" do
    let(:member_presenters) { [generic_work] }
    let(:page) { Capybara::Node::Simple.new(rendered) }
    before do
      allow(view).to receive(:contextual_path).and_return("/concern/generic_works/456")
      allow(model_gw).to receive(:model_name).and_return("GenericWork")
      allow(presenter).to receive(:member_presenters).and_return(member_presenters)
      render 'curation_concerns/base/relationships', presenter: presenter
    end
    it "links to child work" do
      expect(page).to have_link 'Containing work'
    end
    it "labels the link using the presenter's #to_s method" do
      expect(page).not_to have_content 'barbaz'
    end
    it "should not show the empty message" do
      expect(page).to_not have_content "This Work does not have any related works."
    end
  end
end
