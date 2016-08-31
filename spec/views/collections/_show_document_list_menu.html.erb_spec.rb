describe 'collections/_show_document_list_menu.html.erb', type: :view do
  context 'when user is viewing a collection' do
    let(:user) { create :user }
    let(:ability) { instance_double("Ability") }
    let(:document) { SolrDocument.new(id: '1234') }
    before do
      view.extend Sufia::TrophyHelper
      allow(document).to receive(:to_model).and_return(stub_model(GenericWork))
      allow(controller).to receive(:current_ability).and_return(ability)
    end

    it "displays the action list in a drop down for an individual work user can edit" do
      allow(ability).to receive(:can?).with(:edit, document).and_return(true)
      render('collections/show_document_list_menu', document: document, current_user: user)
      expect(rendered).to have_content 'Select an action'
      expect(rendered).to have_content 'Edit'
      expect(rendered).not_to have_content 'Download File'
      expect(rendered).to have_content 'Highlight Work on Profile'
    end

    it "displays the action list in a drop down for individual work user can not edit" do
      allow(ability).to receive(:can?).with(:edit, document).and_return(false)
      render('collections/show_document_list_menu.html.erb', document: document, current_user: user)
      expect(rendered).to have_content 'Select an action'
      expect(rendered).not_to have_content 'Edit'
      expect(rendered).not_to have_content 'Download File'
      expect(rendered).to have_content 'Highlight Work on Profile'
    end

    it "displays the action list in a drop down for individual work without being logged in" do
      render('collections/show_document_list_menu.html.erb', document: document, current_user: false)
      expect(rendered).to have_content 'Select an action'
      expect(rendered).not_to have_content 'Edit'
      expect(rendered).not_to have_content 'Download File'
      expect(rendered).not_to have_content 'Highlight Work on Profile'
    end
  end
end
