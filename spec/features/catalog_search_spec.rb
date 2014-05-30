require 'spec_helper'

include Warden::Test::Helpers

describe_options = { type: :feature }
describe_options[:js] = true if ENV['JS']
describe 'catalog searching', describe_options do


  before :all do
    @gf1 =  GenericFile.new.tap do |f|
      f.title = 'title 1'
      f.tag = ["tag1", "tag2"]
      f.apply_depositor_metadata('jilluser')
      f.read_groups = ['public']
      f.save!
    end
    @gf2 =  GenericFile.new.tap do |f|
      f.title = 'title 2'
      f.tag = ["tag2", "tag3"]
      f.apply_depositor_metadata('jilluser')
      f.read_groups = ['public']
      f.save!
    end
    @col =  Collection.new.tap do |f|
      f.title = 'title 3'
      f.tag = ["tag3", "tag4"]
      f.apply_depositor_metadata('jilluser')
      f.read_groups = ['public']
      f.save!
    end
  end

  after(:all) do
    User.destroy_all
    GenericFile.destroy_all
    Collection.destroy_all
  end

  before do
    sign_in :user
    visit '/'
  end

  it "finds multiple files" do
    within('#masthead_controls') do
      fill_in('search-field-header', with: "tag2")
      click_button("Go")
    end
    page.should have_content('Search Results')
    page.should have_content(@gf1.title.first)
    page.should have_content(@gf2.title.first)
    page.should_not have_content(@col.title)
  end

  it "finds files and collections" do
    within('#masthead_controls') do
      fill_in('search-field-header', with: "tag3")
      click_button("Go")
    end
    page.should have_content('Search Results')
    page.should have_content(@col.title)
    page.should have_content(@gf2.title.first)
    page.should_not have_content(@gf1.title.first)
  end

  it "finds collections" do
    within('#masthead_controls') do
      fill_in('search-field-header', with: "tag4")
      click_button("Go")
    end
    page.should have_content('Search Results')
    page.should have_content(@col.title)
    page.should_not have_content(@gf2.title.first)
    page.should_not have_content(@gf1.title.first)
  end

  context "many tags" do
    before do
      (1..25).each do |i|
        @gf1.tag << "tag#{i.to_s}"
      end
      @gf1.save
      within('#masthead_controls') do
        fill_in('search-field-header', with: "tag1")
        click_button("Go")
      end
    end

    it "allows for browsing tags" do
      page.should have_content('Search Results')
      within('#facet_group') do
        first('a[data-toggle="collapse"]').click
        click_link "more Keywords»"
      end
      click_link "tag18"
      page.should have_content "Search Results"
      click_link @gf1.title[0]
      page.should have_content "Download"
      page.should_not have_content "Edit"
    end

  end
end
