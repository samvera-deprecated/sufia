require 'spec_helper'

describe 'proxy' do
  let!(:current_user) { FactoryGirl.create(:archivist) }
  let!(:second_user) { FactoryGirl.create(:jill) }

  describe 'add proxy in profile' do
    it "creates a proxy" do
      sign_in current_user
      visit "/"
      go_to_user_profile
      click_link "Edit Your Profile"
      first("td.depositor-name").should be_nil
      create_proxy_using_partial(second_user)
      expect(page).to have_css('td.depositor-name', text: second_user.display_name)
    end
  end

  describe 'use a proxy' do
    before(:each) do
      @rights = ProxyDepositRights.create!(grantor: second_user, grantee: current_user)
    end

    it "should allow for on behalf deposit", js: true do
      sign_in current_user
      visit '/'
      first('a.dropdown-toggle').click
      click_link('upload')
      within('#fileupload') do
        page.should have_content('I have read')
        check("terms_of_service")
      end
      select(second_user.user_key, from: 'on_behalf_of')
      test_file_path = File.expand_path('../../fixtures/small_file.txt', __FILE__)
      page.execute_script(%Q{$("input[type=file]").first().css("opacity", "1").css("-moz-transform", "none");$("input[type=file]").first().attr('id',"fileselect");})
      attach_file("fileselect", test_file_path)
      redirect_url = find("#redirect-loc", visible:false).text
      click_button("main_upload_start")
      wait_for_page redirect_url
      page.should have_content('Apply Metadata')
      fill_in('generic_file_title', with: 'MY Title for the World')
      fill_in('generic_file_tag', with: 'test')
      fill_in('generic_file_creator', with: 'me')
      click_on('upload_submit')
      click_link "Shared with Me"
      page.should have_content "MY Title for the World"
      first('i.glyphicon-chevron-right').click
      click_link(second_user.display_name)
    end
  end
end
