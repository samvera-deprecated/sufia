require 'spec_helper'

describe My::FilesController, :type => :controller do

  let(:user) { FactoryGirl.find_or_create(:archivist) }

  before { sign_in user }

  it "should respond with success" do
    get :index
    expect(response).to be_successful
    expect(response).to render_template :index
  end

  it "should paginate" do
    3.times { FactoryGirl.create(:work, user: user) }
    get :index, per_page: 2
    expect(assigns[:document_list].length).to eq 2
    get :index, per_page: 2, page: 2
    expect(assigns[:document_list].length).to be >= 1
  end

  describe "batch processing" do
    include Sufia::Messages
    let (:batch_id) {"batch_id"}
    let (:batch_id2) {"batch_id2"}
    let (:batch) {double}

    before do
      allow(batch).to receive(:id).and_return(batch_id)
      User.batchuser().send_message(user, single_success(batch_id, batch), success_subject, sanitize_text = false)
      User.batchuser().send_message(user, multiple_success(batch_id2, [batch]), success_subject, sanitize_text = false)
      get :index
    end

    it "gets batches that are complete" do
      expect(assigns(:batches).count).to eq(2)
      expect(assigns(:batches)).to include("ss-"+batch_id)
      expect(assigns(:batches)).to include("ss-"+batch_id2)
    end
  end


  context 'with different types of records' do
    let(:someone_else) { FactoryGirl.find_or_create(:user) }

    let!(:my_collection) do
      Collection.new(title: 'test collection').tap do |c|
        c.apply_depositor_metadata(user.user_key)
        c.save!
      end
    end

    let!(:my_work) { FactoryGirl.create(:work, user: user) }
    let!(:shared_work) { FactoryGirl.create(:work, edit_users: [user.user_key], user: someone_else) }
    let!(:unrelated_work) { FactoryGirl.create(:public_work, user: someone_else) }
    let!(:my_file) { FactoryGirl.create(:generic_file, depositor: user) }
    let!(:wrong_type) { Batch.create }

    it 'shows only the correct records' do
      get :index
      doc_ids = assigns[:document_list].map(&:id)
      expect(doc_ids.count).to eq 1

      # shows works I deposited
      expect(doc_ids).to include(my_work.id)
      # doesn't show collections
      expect(doc_ids).to_not include(my_collection.id)
      # doesn't show shared works
      expect(doc_ids).to_not include(shared_work.id)
      # doesn't show other users' works
      expect(doc_ids).to_not include(unrelated_work.id)
      # doesn't show non-works
      expect(doc_ids).to_not include(wrong_type.id)
      expect(doc_ids).to_not include(my_file.id)
    end
  end  # context 'with different types of records'

end
