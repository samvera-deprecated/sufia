require 'spec_helper'

describe 'generic_files/new.html.erb', type: :view do
  let(:user_collections) do
    default_option = SolrDocument.new(id: -1, title_tesim: "Select collection...")
    col1 = SolrDocument.new(id: "c1", title_tesim: "col1")
    col2 = SolrDocument.new(id: "c2", title_tesim: "col2")
    [default_option, col1, col2]
  end
  let(:generic_file) { stub_model(GenericFile, id: '123') }
  let(:batch_id) { 'bi1' }

  describe 'upload_to_collection' do
    before do
      assign(:generic_file, generic_file)
      assign(:batch_id, batch_id)
      assign(:user_collections, user_collections)
      allow(controller).to receive(:current_user).and_return(stub_model(User))
      allow(GenericFilesController).to receive(:upload_complete_path).with(batch_id).and_return("foo")
      Sufia.config.upload_to_collection = upload_to_collection
    end

    context 'when enabled' do
      let(:upload_to_collection) { true }

      it 'appears on page' do
        render
        page = Capybara::Node::Simple.new(rendered)
        expect(page).to have_selector('select#collection', count: 2) # one per tab
      end
    end

    context 'when disabled' do
      let(:upload_to_collection) { false }

      it 'does not appear on page' do
        render
        page = Capybara::Node::Simple.new(rendered)
        expect(page).to have_no_selector('select#collection')
      end
    end
  end
end
