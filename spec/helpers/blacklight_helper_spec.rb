RSpec.describe BlacklightHelper, type: :helper do
  let(:blacklight_config) { CatalogController.blacklight_config }
  let(:attributes) do
    { 'creator_tesim' => ['Justin', 'Joe'],
      'depositor_tesim' => ['jcoyne@justincoyne.com'],
      'proxy_depositor_ssim' => ['atz@stanford.edu'],
      'description_tesim' => ['This links to http://example.com/ What about that?'],
      'date_uploaded_dtsi' => '2013-03-14T00:00:00Z',
      'rights_tesim' => ["http://creativecommons.org/publicdomain/zero/1.0/",
                         "http://creativecommons.org/publicdomain/mark/1.0/",
                         "http://www.europeana.eu/portal/rights/rr-r.html"] }
  end

  let(:document) { SolrDocument.new(attributes) }
  before do
    allow(helper).to receive(:blacklight_config).and_return(blacklight_config)
  end

  describe "render_index_field_value" do
    include SufiaHelper
    subject { render_index_field_value document, field: field_name }

    context "rights_tesim" do
      let(:field_name) { 'rights_tesim' }
      it { is_expected.to eq "<a href=\"http://creativecommons.org/publicdomain/zero/1.0/\">CC0 1.0 Universal</a>, <a href=\"http://creativecommons.org/publicdomain/mark/1.0/\">Public Domain Mark 1.0</a>, and <a href=\"http://www.europeana.eu/portal/rights/rr-r.html\">All rights reserved</a>" }
    end

    context "creator_tesim" do
      let(:joe) { stub_model(User, email: 'atz@stanford.edu') }
      let(:justin) { stub_model(User, email: 'jcoyne@justincoyne.com') }
      let(:search_state) { Blacklight::SearchState.new(params, CatalogController.blacklight_config) }
      before do
        allow(User).to receive(:find_by_user_key).and_return(joe, justin)
        allow(controller).to receive(:search_state).and_return(search_state)
        def search_action_path(stuff)
          search_catalog_path(stuff)
        end
      end
      let(:field_name) { 'creator_tesim' }
      it { is_expected.to eq "<span itemprop=\"creator\"><a href=\"/catalog?f%5Bcreator_tesim%5D%5B%5D=Justin\"><span itemprop=\"creator\">Justin</span></a></span> and <span itemprop=\"creator\"><a href=\"/catalog?f%5Bcreator_tesim%5D%5B%5D=Joe\"><span itemprop=\"creator\">Joe</span></a></span>" }
    end
  end
end
