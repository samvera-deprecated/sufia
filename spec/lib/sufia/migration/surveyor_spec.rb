require 'spec_helper'

describe Sufia::Migration::Survey::Surveyor, type: :model do
  let(:collection) do
    Collection.create(title: "title1", creator: ["creator1"], description: "description1") do |col|
      col.apply_depositor_metadata("jilluser")
    end
  end
  let(:file) { create :generic_file, title: ["my title"] }

  subject { described_class }
  it { is_expected.to respond_to(:call) }

  describe "#call" do
    let(:ids) { [object.id] }
    subject { Sufia::Migration::Survey::Item.where(object_id: object.id).first }

    before do
      described_class.call(ids)
    end

    context "when object is a file" do
      let(:object) { file }

      it "creates a survey item for a file" do
        is_expected.not_to be_nil
        expect(subject.object_id).to eq file.id
        expect(subject.object_class).to eq "GenericFile"
        expect(subject.object_title).to eq file.title.to_s
        expect(subject.initial_state?).to be_truthy
      end
    end

    context "when object is a collection" do
      let(:object) { collection }

      it "creates a survey item for a file" do
        is_expected.not_to be_nil
        expect(subject.object_id).to eq collection.id
        expect(subject.object_class).to eq "Collection"
        expect(subject.object_title).to eq collection.title.to_s
        expect(subject.initial_state?).to be_truthy
      end
    end

    context "when multiple types of objects are passed" do
      let(:ids) { [file.id, collection.id] }
      let(:file_survey) { Sufia::Migration::Survey::Item.where(object_id: file.id).first }
      let(:collection_survey) { Sufia::Migration::Survey::Item.where(object_id: collection.id).first }

      it "creates a survey item for each" do
        expect(file_survey).not_to be_nil
        expect(collection_survey).not_to be_nil
      end
    end
  end

  context "when one of the objects does not exist" do
    let(:ids) { [file.id, "abc123"] }

    it "Errors with out creating any survey items" do
      expect { described_class.call(ids) }.to raise_error(ActiveFedora::ObjectNotFoundError)
      expect(Sufia::Migration::Survey::Item.find_by(object_id: file.id)).to be_nil
    end
  end
end
