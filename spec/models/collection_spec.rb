require 'spec_helper'

describe Collection, type: :model do
  let(:user1) { FactoryGirl.create(:user) }
  let(:public_collection) { create(:public_collection, title: "public collection", creator: ["creator1"], user: user1) }
  let(:private_collection) { create(:private_collection, title: "private collection", creator: ["creator1"], user: user1) }

  it "has open visibility for public collection" do
    public_collection.save
    expect(public_collection.read_groups).to eq ['public']
  end

  it "has no read visibility for private collection" do
    private_collection.save
    expect(private_collection.read_groups).to eq []
  end

  it "does not allow a collection to be saved without a title" do
    public_collection.title = nil
    expect { public_collection.save! }.to raise_error(ActiveFedora::RecordInvalid)
  end

  describe "::bytes" do
    let(:unsaved_collection) { create(:public_collection, title: "unsaved collection", creator: ["creator1"], user: user1) }
    subject { unsaved_collection.bytes }
    context "with no items" do
      it "gets zero without querying solr" do
        expect(ActiveFedora::SolrService).not_to receive(:query)
        is_expected.to eq 0
      end
    end

    context "with three 33 byte files" do
      let(:bitstream) { double("content", size: "33") }
      let(:file) { mock_model GenericFile, content: bitstream }
      let(:documents) do
        [{ 'id' => 'file-1', 'file_size_is' => 33 },
         { 'id' => 'file-2', 'file_size_is' => 33 },
         { 'id' => 'file-3', 'file_size_is' => 33 }]
      end
      let(:query) { ActiveFedora::SolrQueryBuilder.construct_query_for_rel(has_model: ::GenericFile.to_class_uri) }
      let(:args) do
        { fq: "{!join from=hasCollectionMember_ssim to=id}id:#{unsaved_collection.id}",
          fl: "id, file_size_is",
          rows: 3 }
      end

      before do
        allow(unsaved_collection).to receive(:members).and_return([file, file, file])
        allow(ActiveFedora::SolrService).to receive(:query).with(query, args).and_return(documents)
      end

      context "when saved" do
        before do
          allow(unsaved_collection).to receive(:new_record?).and_return(false)
        end
        it { is_expected.to eq 99 }
      end

      context "when not saved" do
        before do
          allow(unsaved_collection).to receive(:new_record?).and_return(true)
        end
        it "raises an error" do
          expect { subject }.to raise_error "Collection must be saved to query for bytes"
        end
      end
    end
  end
end
