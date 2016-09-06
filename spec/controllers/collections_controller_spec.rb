require 'spec_helper'

describe CollectionsController do
  routes { Hydra::Collections::Engine.routes }
  before do
    allow_any_instance_of(User).to receive(:groups).and_return([])
  end

  let(:user) { FactoryGirl.create(:user) }

  describe '#new' do
    before do
      sign_in user
    end

    it 'assigns @collection' do
      get :new
      expect(assigns(:collection)).to be_kind_of(Collection)
    end
  end

  describe '#create' do
    before do
      sign_in user
    end

    it "creates a Collection" do
      expect do
        post :create, collection: { title: "My First Collection ", description: "The Description\r\n\r\nand more" }
      end.to change { Collection.count }.by(1)
    end

    it "removes blank strings from params before creating Collection" do
      expect do
        post :create, collection: {
          title: "My First Collection ", creator: [""] }
      end.to change { Collection.count }.by(1)
      expect(assigns[:collection].title).to eq("My First Collection ")
      expect(assigns[:collection].creator).to eq([])
    end

    it "creates a Collection with files I can access" do
      @asset1 = GenericFile.new(title: ["First of the Assets"])
      @asset1.apply_depositor_metadata(user.user_key)
      @asset1.save
      @asset2 = GenericFile.new(title: ["Second of the Assets"], depositor: user.user_key)
      @asset2.apply_depositor_metadata(user.user_key)
      @asset2.save
      @asset3 = GenericFile.new(title: ["Third of the Assets"], depositor: 'abc')
      @asset3.apply_depositor_metadata('abc')
      @asset3.save
      expect do
        post :create, collection: { title: "My own Collection", description: "The Description\r\n\r\nand more" },
                      batch_document_ids: [@asset1.id, @asset2.id, @asset3.id]
      end.to change { Collection.count }.by(1)
      collection = assigns(:collection)
      expect(collection.members).to match_array [@asset1, @asset2]
    end

    it "adds docs to the collection if a batch id is provided and add the collection id to the documents in the collection" do
      @asset1 = GenericFile.new(title: ["First of the Assets"])
      @asset1.apply_depositor_metadata(user.user_key)
      @asset1.save
      post :create, batch_document_ids: [@asset1.id],
                    collection: { title: "My Second Collection ", description: "The Description\r\n\r\nand more" }
      expect(assigns[:collection].members).to eq [@asset1]
      asset_results = ActiveFedora::SolrService.instance.conn.get "select", params: { fq: ["id:\"#{@asset1.id}\""], fl: ['id', Solrizer.solr_name(:collection)] }
      expect(asset_results["response"]["numFound"]).to eq 1
      doc = asset_results["response"]["docs"].first
      expect(doc["id"]).to eq @asset1.id
      afterupdate = GenericFile.find(@asset1.id)
      expect(doc[Solrizer.solr_name(:collection)]).to eq afterupdate.to_solr[Solrizer.solr_name(:collection)]
    end
  end

  describe "#update" do
    before { sign_in user }

    let(:collection) do
      Collection.create(title: "Collection Title") do |collection|
        collection.apply_depositor_metadata(user.user_key)
      end
    end

    context "a collections members" do
      before do
        @asset1 = GenericFile.new(title: ["First of the Assets"])
        @asset1.apply_depositor_metadata(user.user_key)
        @asset1.save
        @asset2 = GenericFile.new(title: ["Second of the Assets"], depositor: user.user_key)
        @asset2.apply_depositor_metadata(user.user_key)
        @asset2.save
        @asset3 = GenericFile.new(title: ["Third of the Assets"], depositor: 'abc')
        @asset3.apply_depositor_metadata(user.user_key)
        @asset3.save
      end

      it "sets collection on members" do
        put :update, id: collection, collection: { members: "add" }, batch_document_ids: [@asset3.id, @asset1.id, @asset2.id]
        expect(response).to redirect_to routes.url_helpers.collection_path(collection)
        expect(assigns[:collection].members).to match_array [@asset2, @asset3, @asset1]
        asset_results = ActiveFedora::SolrService.instance.conn.get "select", params: { fq: ["id:\"#{@asset2.id}\""], fl: ['id', Solrizer.solr_name(:collection)] }
        expect(asset_results["response"]["numFound"]).to eq 1
        doc = asset_results["response"]["docs"].first
        expect(doc["id"]).to eq @asset2.id
        afterupdate = GenericFile.find(@asset2.id)
        expect(doc[Solrizer.solr_name(:collection)]).to eq afterupdate.to_solr[Solrizer.solr_name(:collection)]
        put :update, id: collection, collection: { members: "remove" }, batch_document_ids: [@asset2]
        asset_results = ActiveFedora::SolrService.instance.conn.get "select", params: { fq: ["id:\"#{@asset2.id}\""], fl: ['id', Solrizer.solr_name(:collection)] }
        expect(asset_results["response"]["numFound"]).to eq 1
        doc = asset_results["response"]["docs"].first
        expect(doc["id"]).to eq @asset2.id
        GenericFile.find(@asset2.id)
        expect(doc[Solrizer.solr_name(:collection)]).to be_nil
      end
    end

    context "updating a collections metadata" do
      it "saves the metadata" do
        put :update, id: collection, collection: { creator: ['Emily'] }
        collection.reload
        expect(collection.creator).to eq ['Emily']
      end

      it "removes blank strings from params before updating Collection metadata" do
        put :update, id: collection, collection: {
          title: "My Next Collection ", creator: [""] }
        expect(assigns[:collection].title).to eq("My Next Collection ")
        expect(assigns[:collection].creator).to eq([])
      end
    end

    context "when user has edit permissions on a collection" do
      before do
        @asset1 = GenericFile.new(title: ["First of the Assets"])
        @asset1.apply_depositor_metadata(user.user_key)
        @asset1.save
        @asset2 = GenericFile.new(title: ["Second of the Assets"], depositor: user.user_key)
        @asset2.apply_depositor_metadata(user.user_key)
        @asset2.save
        @asset3 = GenericFile.new(title: ["Third of the Assets"], depositor: 'abc')
        @asset3.apply_depositor_metadata(user.user_key)
        @asset3.save
      end

      let(:private_collection) {
        create(:private_collection,
               title: "My private collection",
               description: "My incredibly detailed description of the private collection",
               user: user)
      }

      it "sets the groups" do
        post :update, id: private_collection,
                      "collection" => { "permissions_attributes" => [{ "type" => "group", "name" => "group1", "access" => "read" }] }
        private_collection.reload
        expect(private_collection.read_groups).to include "group1"
        expect(response).to redirect_to routes.url_helpers.collection_path(private_collection.id)
      end

      it "sets public read access" do
        post :update, id: private_collection, visibility: "open", collection: { tag: [""] }
        expect(private_collection.reload.read_groups).to eq ['public']
      end

      it "adds new groups and users" do
        post :update, id: private_collection,
                      collection: { permissions_attributes: [
                        { type: 'person', name: 'user1', access: 'edit' },
                        { type: 'group', name: 'group1', access: 'read' }] }
        private_collection.reload
        expect(private_collection.read_groups).to include "group1"
        expect(private_collection.edit_users).to include "user1"
      end

      it "updates existing groups and users" do
        private_collection.edit_groups = ['group3']
        private_collection.save
        post :update, id: private_collection,
                      collection: { permissions_attributes: [
                        { id: private_collection.permissions.last.id, type: 'group', name: 'group3', access: 'read' }] }
        private_collection.reload
        expect(private_collection.read_groups).to eq(["group3"])
      end

      it "sets metadata like title" do
        post :update, id: private_collection, collection: { tag: ["footag", "bartag"], title: "New Title" }
        private_collection.reload
        expect(private_collection.title).to eq "New Title"
        # TODO: is order important?
        expect(private_collection.tag).to include("footag", "bartag")
      end

      it "does not set any tags" do
        post :update, id: private_collection, collection: { tag: [""] }
        expect(private_collection.reload.tag).to be_empty
      end
    end

    context "when user does not have edit permissions on a collection" do
      # TODO: all these tests could move to batch_update_job_spec.rb
      let(:private_collection) {
        create(:private_collection,
               title: 'Original Title',
               user: user)
      }

      it "does not modify the object" do
        post :update, id: private_collection, "collection" => { "read_groups_string" => "group1, group2", "read_users_string" => "", "tag" => [""] },
                      "title" => { private_collection.id => "Title Wont Change" }
        private_collection.reload
        expect(private_collection.title).to eq "Original Title"
        expect(private_collection.read_groups).to eq []
      end
    end
  end

  describe "#show" do
    let(:asset1) do
      GenericFile.new(title: ["First of the Assets"]) do |gf|
        gf.apply_depositor_metadata(user)
        gf.visibility = "open"
      end
    end

    let(:asset2) do
      GenericFile.new(title: ["Second of the Assets"]) do |gf|
        gf.apply_depositor_metadata(user)
        gf.visibility = "open"
      end
    end

    let(:asset3) do
      GenericFile.new(title: ["Third of the Assets"]) do |gf|
        gf.apply_depositor_metadata(user)
        gf.visibility = "open"
      end
    end

    let(:public_collection) {
      create(:public_collection,
             title: "My public collection",
             description: "My incredibly detailed description of the public collection",
             members: [asset1, asset2, asset3],
             user: user)
    }

    let(:private_collection) {
      create(:private_collection,
             title: "My private collection",
             description: "My incredibly detailed description of the private collection",
             members: [asset1, asset2, asset3],
             user: user)
    }

    context "when signed in" do
      before { sign_in user }

      it "returns the public collection and its members" do
        expect(controller).to receive(:add_breadcrumb).with(I18n.t('sufia.dashboard.title'), Sufia::Engine.routes.url_helpers.dashboard_index_path)
        get :show, id: public_collection
        expect(response).to be_successful
        expect(assigns[:presenter]).to be_kind_of Sufia::CollectionPresenter
        expect(assigns[:collection].title).to eq public_collection.title
        expect(assigns[:member_docs].map(&:id)).to match_array [asset1, asset2, asset3].map(&:id)
      end

      it "returns the private collection and its members" do
        expect(controller).to receive(:add_breadcrumb).with(I18n.t('sufia.dashboard.title'), Sufia::Engine.routes.url_helpers.dashboard_index_path)
        get :show, id: private_collection
        expect(response).to be_successful
        expect(assigns[:presenter]).to be_kind_of Sufia::CollectionPresenter
        expect(assigns[:collection].title).to eq private_collection.title
        expect(assigns[:member_docs].map(&:id)).to match_array [asset1, asset2, asset3].map(&:id)
      end
    end

    context "not signed in" do
      it "returns the public collection and its members" do
        get :show, id: public_collection
        expect(response).to be_successful
        expect(assigns[:presenter]).to be_kind_of Sufia::CollectionPresenter
        expect(assigns[:collection].title).to eq public_collection.title
        expect(assigns[:member_docs].map(&:id)).to match_array [asset1, asset2, asset3].map(&:id)
      end

      it "does not show me files in the private collection" do
        get :show, id: private_collection
        expect(response).to redirect_to Rails.application.routes.url_helpers.new_user_session_path
      end
    end
  end

  describe "#edit" do
    let(:collection) do
      Collection.create(title: "My collection",
                        description: "My incredibly detailed description of the collection") do |c|
        c.apply_depositor_metadata(user)
      end
    end

    before { sign_in user }

    it "does not show flash" do
      get :edit, id: collection
      expect(flash[:notice]).to be_nil
    end
  end
end
