require 'spec_helper'

describe 'generic_files/edit.html.erb', :no_clean do
  let(:content) { double('content', mimeType: 'application/pdf') }

  let(:generic_file) do
    stub_model(GenericFile, id: '123',
                            depositor: 'bob',
                            resource_type: ['Book', 'Dataset'])
  end

  let(:form) do
    Sufia::Forms::GenericFileEditForm.new(generic_file)
  end

  let(:page) do
    render
    Capybara::Node::Simple.new(rendered)
  end

  subject { page }

  before do
    allow(generic_file).to receive(:content).and_return(content)
    allow(controller).to receive(:current_user).and_return(stub_model(User))
    assign(:generic_file, generic_file)
    assign(:form, form)
    assign(:version_list, [])
  end

  it { is_expected.to have_button('Save Descriptions') }

  describe 'when the file has two or more resource types' do
    let(:resource_version) do
      ActiveFedora::VersionsGraph::ResourceVersion.new.tap do |v|
        v.uri = 'http://example.com/version1'
        v.label = 'version1'
        v.created = '2014-12-09T02:03:18.296Z'
      end
    end

    let(:version_list) { Sufia::VersionListPresenter.new([resource_version]) }
    let(:versions_graph) { double(all: [version1]) }

    it "only draws one resource_type multiselect" do
      assign(:version_list, version_list)
      expect(page).to have_selector("select#generic_file_resource_type", count: 1)
    end
  end
end
