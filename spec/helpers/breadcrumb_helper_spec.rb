require 'spec_helper'

describe BreadcrumbHelper do

  let(:request) { double("request", referer: referer) }

  context "when comming from the catalog" do
    let! (:referer) { "http://...catalog" }
    specify "then the first crumb link to the homepage should be omitted" do
      allow(view).to receive(:request).and_return(request)
      expect(helper.breadcrumb_links.first).to include(t('sufia.bread_crumb.search_results'))
    end
  end

  context "when comming from the user's dashboard" do
    let! (:referer) { "http://...dashboard" }
    specify "then the only crumb link should be back to the user's dashboard" do
      allow(view).to receive(:request).and_return(request)
      expect(helper.breadcrumb_links.first).to include(t('sufia.dashboard.title'))
    end
  end

  context "when comming from the user's files" do
    let! (:referer) { "http://...dashboard/files" }
    specify "then the first crumb link should be back to the user's dashboard" do
      allow(view).to receive(:request).and_return(request)
      expect(helper.breadcrumb_links.first).to include(t('sufia.dashboard.title'))
    end
    specify "then the second crumb should be back to the user's files" do
      allow(view).to receive(:request).and_return(request)
      expect(helper.breadcrumb_links.second).to include(t('sufia.dashboard.my.files'))     
    end
  end

  context "when comming from the user's collections" do
    let! (:referer) { "http://...dashboard/collections" }
    specify "then the first crumb link should be back to the user's dashboard" do
      allow(view).to receive(:request).and_return(request)
      expect(helper.breadcrumb_links.first).to include(t('sufia.dashboard.title'))
    end
    specify "then the second crumb should be back to the user's collections" do
      allow(view).to receive(:request).and_return(request)
      expect(helper.breadcrumb_links.second).to include(t('sufia.dashboard.my.collections'))     
    end
  end

end
