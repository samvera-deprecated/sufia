require 'spec_helper'

describe "Browse Dashboard" do

  before :all do
    cleanup_jetty
    @fixtures = find_or_create_file_fixtures
  end
  after :all do
    cleanup_jetty
  end

  before do
    sign_in FactoryGirl.create :user_with_fixtures
  end

  it "should search your files by deafult" do
    visit "/dashboard"
    fill_in "q", with: "PDF"
    click_button "search-submit-header"
    expect(page).to have_content("Fake Document Title")
  end

  context "within my files page" do

    before do
      visit "/dashboard/files"
    end

    it "should display all the necessary information" do
      within("#document_#{@fixtures.first.noid}") do
        click_button("Select an action")
      end
      expect(page).to have_content("Edit File")
      expect(page).to have_content("Download File")
      expect(page).to_not have_content("Is part of:")
      first(".label-success") do
        expect(page).to have_content("Open Access")
      end
      expect(page).to have_link("Create Collection")
      expect(page).to have_link("Upload")
    end

    it "should allow you to search your own files and remove constraints" do
      fill_in "q", with: "PDF"
      click_button "search-submit-header"
      expect(page).to have_content("Fake Document Title")
      within(".constraints-container") do
        expect(page).to have_content("You searched for:")
        expect(page).to have_css("span.glyphicon-remove")
        find(".dropdown-toggle").click
      end
      expect(page).to have_content("Fake Wav File")
    end

    it "should allow you to browse facets" do
      click_link "Subject"
      click_link "more Subjects"
      click_link "consectetur"
      within("#document_#{@fixtures[1].noid}") do
        click_link "Display all details of Test Document MP3.mp3"
      end
      expect(page).to have_content("File Details")
    end

    it "should allow me to edit files (from the fixtures)" do
      fill_in "q", with: "Wav"
      click_button "search-submit-header"
      click_button "Select an action"
      click_link "Edit File"
      expect(page).to have_content("Edit Fake Wav File.wav")
    end

    it "should refresh the page of files" do
      click_button "Refresh"
      within("#document_#{@fixtures.first.noid}") do
        click_button("Select an action")
        expect(page).to have_content("Edit File")
        expect(page).to have_content("Download File")
      end
    end

    it "should allow me to edit files in batches" do
      first('input#check_all').click
      click_button('Edit Selected')
      expect(page).to have_content('3 files')
    end

    it "should link to my other tabs" do
      ["My Collections", "My Highlights", "Files Shared with Me"].each do |tab|
        within("#my_nav") do
          click_link(tab)
        end
        expect(page).to have_content(tab)
      end
    end

  end

end
