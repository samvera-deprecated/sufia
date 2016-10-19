require 'spec_helper'

describe Sufia::Migration::Survey::FedoraIdService do
  it { is_expected.to respond_to(:register_model) }
  it { is_expected.to respond_to(:call) }

  let(:service) { described_class.new }

  describe "default registry" do
    subject { service.model_registry }
    it { is_expected.to eq([::GenericFile, ::Collection]) }
  end

  describe "#register_model" do
    subject { service.model_registry }

    let(:model_class) { TestModel }
    before do
      class TestModel < ActiveFedora::Base; end
    end
    after do
      Object.send(:remove_const, :TestModel)
    end

    it "registers a model" do
      service.register_model(model_class)
      is_expected.to include(model_class)
    end

    it "registers a model once" do
      service.register_model(model_class)
      service.register_model(model_class)
      expect(subject.count(model_class)).to eq(1)
    end
    context "invalid model" do
      let(:model_class) { String }
      it "throws an error" do
        expect { service.register_model(model_class) }.to raise_error(Sufia::Migration::Survey::RegistryError)
        is_expected.not_to include(model_class)
      end
    end
  end

  describe "#call" do
    let!(:file) { create :generic_file }
    let!(:collection) do
      Collection.create(title: "title1", creator: ["creator1"], description: "description1") do |col|
        col.apply_depositor_metadata("jilluser")
      end
    end
    subject { service.call }

    it "finds the model ids" do
      is_expected.to include(file.id, collection.id)
      expect(subject.count).to eq 2
    end

    context "we only want a limited set" do
      subject { service.call(1) }

      it "finds the model ids" do
        is_expected.to include(file.id)
        expect(subject.count).to eq 1
      end
    end

    context "we get a blank model back" do
      before do
        original_to_solr = file.to_solr
        original_to_solr["has_model_ssim"] = nil
        allow(file).to receive(:to_solr).and_return(original_to_solr)
        file.update_index
      end

      it "finds the collection id" do
        is_expected.to include(collection.id)
        expect(subject.count).to eq 1
      end
    end
  end
end
