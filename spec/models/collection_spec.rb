require 'spec_helper'

describe Collection, :type => :model do
  before do
    @user = FactoryGirl.create(:user)
    @collection = Collection.new(id: 'mock-collection-with-members', title: "test collection") do |c|
      c.apply_depositor_metadata(@user.user_key)
    end
  end

  it "should have open visibility" do
    @collection.save
    expect(@collection.read_groups).to eq ['public']
  end

  it "should not allow a collection to be saved without a title" do
     @collection.title = nil
     expect{ @collection.save! }.to raise_error(ActiveFedora::RecordInvalid)
  end

  describe "::bytes" do
    subject { @collection.bytes }
    context "with no items" do
      it "gets zero without querying solr" do
        expect(ActiveFedora::SolrService).not_to receive(:query)
        is_expected.to eq 0
      end
    end

    context "with three 33 byte files" do
      let(:bitstream) { double("content", size: "33")}
      let(:file) { mock_model GenericFile, content: bitstream }
      let(:documents) do
        [{ 'id' => 'file-1', 'file_size_is' => 33 }, 
         { 'id' => 'file-2', 'file_size_is' => 33 }, 
         { 'id' => 'file-3', 'file_size_is' => 33 }]
      end
      let(:query) { ActiveFedora::SolrQueryBuilder.construct_query_for_rel(has_model: ::GenericFile.to_class_uri) }
      let(:args) do
        { fq: "{!join from=hasCollectionMember_ssim to=id}id:#{@collection.id}",
        fl: "id, file_size_is",
        rows: 3 }
      end

      before do
        allow(@collection).to receive(:members).and_return([file, file, file])
        allow(ActiveFedora::SolrService).to receive(:query).with(query, args).and_return(documents)
      end

      context "when saved" do
        before do
          allow(@collection).to receive(:new_record?).and_return(false)
        end
        it { is_expected.to eq 99 }
      end

      context "when not saved" do
        it "raises an error" do
          expect { subject }.to raise_error "Collection must be saved to query for bytes"
        end
      end
    end

  end
end
