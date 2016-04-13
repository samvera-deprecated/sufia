require 'spec_helper'

describe 'curation_concerns/file_sets/_actions.html.erb', type: :view do
  let(:user) { create(:user) }
  let(:solr_document) {
    SolrDocument.new(
      id: '999',
      object_profile_ssm: ["{\"id\":\"999\"}"],
      has_model_ssim: ['FileSet'],
      human_readable_type_tesim: ['File'],
      contributor_tesim: ['Frodo'],
      creator_tesim: ['Bilbo'],
      rights_tesim: ['http://creativecommons.org/licenses/by/3.0/us/']
    )
  }
  let(:file_set) {
    stub_model(FileSet, id: '123',
                        depositor: 'bob',
                        resource_type: ['Dataset'])
  }
  let(:ability) { Ability.new(user) }

  describe 'single-use link' do
    let(:page) { Capybara::Node::Simple.new(rendered) }
    before do
      allow(view).to receive(:file_set).and_return(file_set)
      allow(controller).to receive(:can?).with(:destroy, file_set.id).and_return(true)
      allow(controller).to receive(:can?).with(:read, file_set.id).and_return(true)
    end

    context 'when user can edit the file' do
      before do
        allow(controller).to receive(:can?).with(:edit, file_set.id).and_return(true)
        render
      end
      it 'single-use link appears on page' do
        expect(page).to have_link('Single-Use Link', count: 1)
      end
    end

    context 'when user cannot edit the file' do
      before do
        allow(controller).to receive(:can?).with(:edit, file_set.id).and_return(false)
        render
      end
      it 'single-user link does not appear on the page' do
        expect(page).to_not have_content('Single-Use')
      end
    end
  end
end
