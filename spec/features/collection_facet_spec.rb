require 'spec_helper'

describe "Collection Facet", type: :feature do
  def visit_dashboard_my_files
    visit '/dashboard/files'
    expect(page.title).to eq 'Files listing'
    expect(page).to have_link('My Files')
    expect(page).to have_link('My Collections')
    expect(page).to have_link('Fake PDF Title')
    expect(page).to have_css('h3', text: 'Filter your files')
  end

  def search_for_files
    visit '/'
    fill_in('search-field-header', with: 'pdf')
    click_button('search-submit-header')
    expect(page.title).to eq 'Keyword: pdf - Blacklight Search Results'
    expect(page).to have_link('Fake PDF Title')
    expect(page).to have_css('h4', text: 'Limit your search')
  end

  def facet?(page)
    f = page.all('a', text: /\ACollection\z/)
    return true if f.size == 1
    false
  end

  let(:auser) { FactoryGirl.create(:curator) }

  let!(:fixtures) do
    create_file_fixtures(auser.user_key, [:public_pdf]) do |f|
      f.tag = ['pdf']
      f.apply_depositor_metadata(auser.user_key)
    end
  end

  let(:collection1) do
    Collection.create(title: 'Test Collection 1', description: 'Description for collection 1',
                      members: []) { |c| c.apply_depositor_metadata(auser.user_key) }
  end

  context "with collection having a member" do
    before do
      Sufia.config.collection_facet = :public
      collection1.add_members([fixtures[0].id])
      collection1.save
      fixtures[0].update_index
    end

    context "and collection_facet config == :user" do
      before do
        Sufia.config.collection_facet = :user
      end

      it "shows collection facet in Dashboard -> My Files" do
        login_as auser
        visit_dashboard_my_files
        expect(facet?(page)).to eq true
      end

      it "does show collection facet in pubic search with user logged in" do
        login_as auser
        search_for_files
        expect(facet?(page)).to eq true
      end

      it "does NOT show collection facet in pubic search with user NOT logged in" do
        search_for_files
        expect(facet?(page)).to eq false
      end
    end

    context "and collection_facet config == :public" do
      before do
        Sufia.config.collection_facet = :public
      end

      it "shows collection facet in Dashboard -> My Files" do
        login_as auser
        visit_dashboard_my_files
        expect(facet?(page)).to eq true
      end

      it "shows collection facet in pubic search with user logged in" do
        login_as auser
        search_for_files
        expect(facet?(page)).to eq true
      end

      it "shows collection facet in pubic search with user NOT logged in" do
        search_for_files
        expect(facet?(page)).to eq true
      end
    end

    context "and collection_facet config == nil" do
      before do
        Sufia.config.collection_facet = nil
      end

      it "does NOT show collection facet in Dashboard -> My Files" do
        login_as auser
        visit_dashboard_my_files
        expect(facet?(page)).to eq false
      end

      it "does NOT show collection facet in pubic search with user logged in" do
        login_as auser
        search_for_files
        expect(facet?(page)).to eq false
      end

      it "does NOT show collection facet in pubic search with user NOT logged in" do
        search_for_files
        expect(facet?(page)).to eq false
      end
    end
  end
end
