require 'spec_helper'

describe PagesController do
  describe "#create" do

    context "with access" do
      context "for an existing record" do
        let(:page) { Page.create!(name: "about_page", value: "foo bar") }
        before do
          expect(controller).to receive(:authorize!).with(:update, page)
        end

        it "should update the node" do
          post :create, id: page.name, content: { about_page: {value: "better text"}}, format: 'json'
          expect(response).to be_successful
          expect(page.reload.value).to eq 'better text'
        end
      end

      context "for a new record" do
        before do
          expect(controller).to receive(:authorize!).with(:update, an_instance_of(Page))
        end

        it "should create the node" do
          expect {
            post :create, id: 'about_page', content: { about_page: {value: "better text"}}, format: 'json'
          }.to change {Page.count}.by(1)
          expect(response).to be_successful
        end
      end
    end

    context "with no access" do
      it "should create the node" do
        expect {
        post :create, id: 'about_page', content: { about_page: {value: "better text"}}, format: 'json'
        }.to raise_error CanCan::AccessDenied, "You are not authorized to access this page."
      end
    end
  end

  describe "GET #show" do
    let(:page) { Page.create!(name: "about_page", value: "foo bar") }

    it "should update the node" do
      get :show, id: page.name
      expect(response).to be_successful
      expect(assigns[:page]).to eq page
    end
  end
end
