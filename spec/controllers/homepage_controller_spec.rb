require 'spec_helper'

describe HomepageController do
  routes { Rails.application.class.routes }

  describe "#index" do
    before :all do
      GenericFile.delete_all
      @gf1 = GenericFile.new(title:'Test Document PDF', filename:'test.pdf', tag:'rocks', read_groups:['public'])
      @gf1.apply_depositor_metadata('mjg36')
      @gf1.save
      @gf2 = GenericFile.new(title:'Test 2 Document', filename:'test2.doc', tag:'clouds', contributor:'Contrib1', read_groups:['public'])
      @gf2.apply_depositor_metadata('mjg36')
      @gf2.save
    end

    after :all do
      @gf1.delete
      @gf2.delete
    end

    let(:user) { FactoryGirl.find_or_create(:jill) }
    before do
      sign_in user
    end

    it "should set featured researcher" do
      get :index
      expect(response).to be_success
      assigns(:featured_researcher).tap do |researcher|
        expect(researcher).to be_kind_of ContentBlock
        expect(researcher.name).to eq 'featured_researcher'
      end
    end

    it "should set marketing text" do
      get :index
      expect(response).to be_success
      assigns(:marketing_text).tap do |marketing|
        expect(marketing).to be_kind_of ContentBlock
        expect(marketing.name).to eq 'marketing_text'
      end
    end

    context "with featured works" do
      before do
        FeaturedWork.create!(generic_file_id: @gf1.id)
      end

      it "should set featured works" do
        get :index
        expect(response).to be_success
        expect(assigns(:featured_work_list)).to be_kind_of FeaturedWorkList
      end
    end
  end
end
