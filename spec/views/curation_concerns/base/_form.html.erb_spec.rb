require 'spec_helper'

describe 'curation_concerns/base/_form.html.erb' do
  let(:work) do
    stub_model(Work, id: '456')
  end
  let(:ability) { double }

  let(:form) do
    CurationConcerns::WorkForm.new(work, ability)
  end

  before do
    view.lookup_context.view_paths.push 'app/views/curation_concerns'
    allow(work).to receive(:member_ids).and_return([1, 2])
    allow(view).to receive(:curation_concern).and_return(work)
    allow(controller).to receive(:current_user).and_return(stub_model(User))
    assign(:form, form)
  end

  let(:page) do
    render
    Capybara::Node::Simple.new(rendered)
  end

  context "for a new object" do
    let(:work) { Work.new }
    it "routes to the WorkController" do
      expect(page).to have_selector("form[action='/concern/works']")
    end

    it "has a switch to Batch Upload link" do
      expect(page).to have_link('Batch upload')
    end

    context 'with browse-everything disabled (default)' do
      before do
        allow(Sufia.config).to receive(:browse_everything) { nil }
      end
      it 'does not render the BE upload widget' do
        expect(page).not_to have_selector('button#browse-btn')
      end
    end

    context 'with browse-everything enabled' do
      before do
        allow(Sufia.config).to receive(:browse_everything) { 'not nil' }
      end
      it 'renders the BE upload widget' do
        expect(page).to have_selector('button#browse-btn')
      end
    end

    describe 'uploading a folder' do
      context 'with Chrome' do
        before { allow(view).to receive(:browser_supports_directory_upload?) { true } }
        it 'renders the add folder button' do
          expect(page).to have_content('Add folder...')
        end
      end
      context 'with a non-Chrome browser' do
        before { allow(view).to receive(:browser_supports_directory_upload?) { false } }
        it 'does not render the add folder button' do
          expect(page).not_to have_content('Add folder...')
        end
      end
    end
  end

  context "for a persisted object" do
    it "routes to the WorkController" do
      expect(page).to have_selector("form[action='/concern/works/456']")
    end

    describe 'when the work has two or more resource types' do
      it "only draws one resource_type multiselect" do
        expect(page).to have_selector("select#work_resource_type", count: 1)
      end
      it "allows to change the thumbnail" do
        expect(page).to have_selector("select#work_thumbnail_id", count: 1)
      end
      it "allows to change the representative media" do
        expect(page).to have_selector("select#work_representative_id", count: 1)
      end
    end

    it "doesn't have switch to Batch Upload link" do
      expect(page).not_to have_link('Batch upload', href: '/batch_uploads')
    end

    it "renders the link for the Cancel button" do
      expect(page).to have_link("Cancel", href: "/dashboard")
    end
  end
end
