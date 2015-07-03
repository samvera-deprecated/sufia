require 'spec_helper'

describe "Browse Dashboard", type: :feature do
  let(:user) { FactoryGirl.create(:user) }
  let!(:fixtures) { create_file_fixtures(user.user_key, handles) }

  before do
    sign_in user
  end

  context "within dashboard" do
    let(:handles) { [:public_pdf] }

    it "should search your files by default" do
      visit "/dashboard"
      fill_in "q", with: "PDF"
      click_button "search-submit-header"
      expect(page).to have_content("Fake PDF Title")
    end
  end

  context "within my files page" do

    before do
      visit "/dashboard/files"
    end

    context "no files" do
      let(:handles) { [ ] }

      it "should link to my other tabs" do
        # TODO this would make a good view test.
        ["My Collections", "My Highlights", "Files Shared with Me"].each do |tab|
          within("#my_nav") do
            click_link(tab)
          end
          expect(page).to have_content(tab)
        end
      end
    end

    context "with one file" do
      let(:handles) { [ :public_pdf ] }

      it "should display all the necessary information" do
        # TODO this would make a good view test.
        within("#document_#{fixtures.first.id}") do
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
    end

    context "with three files" do
      let(:handles) { [:public_pdf, :public_mp3, :public_wav] }

      it "allows you to interact your own files" do

      #refreshes the page of files
        # TODO this would make a good view test.
        click_button "Refresh"
        within("#document_#{fixtures.first.id}") do
          click_button("Select an action")
          expect(page).to have_content("Edit File")
          expect(page).to have_content("Download File")
        end

      # allows you to search your own files and remove constraints
        fill_in "q", with: "PDF"
        click_button "search-submit-header"
        expect(page).to have_content("Fake PDF Title")
        within(".constraints-container") do
          expect(page).to have_content("You searched for:")
          expect(page).to have_css("span.glyphicon-remove")
          find(".dropdown-toggle").click
        end
        expect(page).to have_content("Fake Wav File")

      # allows you to browse facets
        visit "/dashboard/files"
        click_link "Subject"
        click_link "more Subjects"
        click_link "consectetur"
        within("#document_#{fixtures[1].id}") do
          click_link "Display all details of Test Document MP3.mp3"
        end
        expect(page).to have_content("File Details")

      # allows me to edit files (from the fixtures)
        # TODO this would make a good view test.
        visit "/dashboard/files"

        fill_in "q", with: "Wav"
        click_button "search-submit-header"
        click_button "Select an action"
        click_link "Edit File"
        expect(page).to have_content("Edit Fake Wav File.wav")

      # allows me to edit files in batches"
        visit "/dashboard/files"

        first('input#check_all').click
        click_button('Edit Selected')
        expect(page).to have_content('3 files')

      end
    end
  end

end
