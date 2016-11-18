require 'spec_helper'

describe Sufia::Migration::Validation::Service, type: :model do
  let(:service) { described_class.new }
  describe "#register_model_mapping" do
    subject { service.register(original_class, new_class) }

    context "valid class" do
      let(:original_class) { Collection }
      let(:new_class) { FileSet }
      it { is_expected.to eq(Collection: FileSet, GenericFile: GenericWork) }
    end

    context "new class" do
      let(:original_class) { 'Batch' }
      let(:new_class) { FileSet }
      it { is_expected.to eq(Batch: FileSet, Collection: Collection, GenericFile: GenericWork) }
    end

    context "invalid class" do
      let(:original_class) { Collection }
      let(:new_class) { "abc123" }
      it "raises an error" do
        expect { subject }.to raise_exception
      end
    end
  end

  describe "#call" do
    let(:work) { create :work }
    let!(:valid_item) do
      Sufia::Migration::Survey::Item.create(
        object_id: work.id,
        object_class: 'GenericFile',
        object_title: work.title.to_s,
        migration_status: :initial_state
      )
    end
    let!(:invalid_item) do
      Sufia::Migration::Survey::Item.create(
        object_id: work.id,
        object_class: 'Collection',
        object_title: work.title.to_s,
        migration_status: :initial_state
      )
    end
    let!(:missing_item) do
      Sufia::Migration::Survey::Item.create(
        object_id: 'blah',
        object_class: 'GenericFile',
        object_title: work.title.to_s,
        migration_status: :initial_state
      )
    end

    before do
      service.call
    end

    it "validate the items" do
      expect(valid_item.reload.migration_status).to eq 'successful'
      expect(invalid_item.reload.migration_status).to eq 'wrong_type'
      expect(missing_item.reload.migration_status).to eq 'missing'
    end
  end
end
