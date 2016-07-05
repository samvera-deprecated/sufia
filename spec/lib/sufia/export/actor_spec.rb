require 'spec_helper'

describe Sufia::Export::Actor do
  let(:actor) { described_class.new }
  subject { actor }
  describe "methods" do
    it { is_expected.to respond_to(:register_converter) }
    it { is_expected.to respond_to(:call) }
  end
  describe "register_convertor" do
    let(:model_class) { TestModel }
    let(:converter_class) { TestConverter }
    before do
      class TestModel < ActiveFedora::Base; end
      class TestConverter < Sufia::Export::Converter; end
    end

    after do
      Object.send(:remove_const, :TestModel)
      Object.send(:remove_const, :TestConverter)
    end

    subject { actor.converter_registry }
    it "registers a converter" do
      actor.register_converter(model_class, converter_class)
      is_expected.to have_key(model_class)
      is_expected.to have_value(converter_class)
    end
    context "invalid model" do
      let(:model_class) { String.class }
      it "throws an error" do
        expect { actor.register_converter(model_class, converter_class) }.to raise_error(Sufia::Export::RegistryError)
        is_expected.not_to have_key(model_class)
        is_expected.not_to have_value(converter_class)
      end
    end
    context "invalid converter" do
      let(:converter_class) { String.class }
      it "throws an error" do
        expect { actor.register_converter(model_class, converter_class) }.to raise_error(Sufia::Export::RegistryError)
        is_expected.not_to have_key(model_class)
        is_expected.not_to have_value(converter_class)
      end
    end
    context "default values" do
      it { is_expected.to eq(GenericFile => Sufia::Export::GenericFileConverter, Collection => Sufia::Export::CollectionConverter) }
    end
  end

  describe "call" do
    let!(:file) { create :generic_file }
    let!(:collection) do
      Collection.create(title: "title1", creator: ["creator1"], description: "description1") do |col|
        col.apply_depositor_metadata("jilluser")
      end
    end
    let(:options) { {} }
    let(:generic_file_converter) { Sufia::Export::GenericFileConverter.new(file) }
    let(:generic_file_file_name) { "tmp/export/generic_file_#{file.id}.json" }
    let(:collection_converter) { Sufia::Export::CollectionConverter.new(collection) }
    let(:collection_file_name) { "tmp/export/collection_#{collection.id}.json" }
    after do
      FileUtils.rm_r("tmp/export") if Dir.exist?("tmp/export")
    end

    it "converts files and collections by default" do
      expect(Sufia::Export::GenericFileConverter).to receive(:new).and_return(generic_file_converter)
      expect(Sufia::Export::CollectionConverter).to receive(:new).and_return(collection_converter)
      expect(collection_converter).to receive(:to_json).and_return("collection json goes here")
      expect(generic_file_converter).to receive(:to_json).and_return("generic file json goes here")
      expect { actor.call }.not_to raise_error
      expect(File.exist?(generic_file_file_name)).to be_truthy
      expect(File.exist?(collection_file_name)).to be_truthy
      expect(File.read(collection_file_name)).to eq("collection json goes here")
      expect(File.read(generic_file_file_name)).to eq("generic file json goes here")
    end

    it "converts files" do
      expect(Sufia::Export::GenericFileConverter).to receive(:new).and_return(generic_file_converter)
      expect(generic_file_converter).to receive(:to_json).and_return("generic file json goes here")
      expect { actor.call([GenericFile], options) }.not_to raise_error
      expect(File.exist?(generic_file_file_name)).to be_truthy
      expect(File.read(generic_file_file_name)).to eq("generic file json goes here")
    end

    it "limits the files created" do
      expect { actor.call([GenericFile, Collection], limit: 1) }.not_to raise_error
      expect(File.exist?(generic_file_file_name)).to be_truthy
      expect(File.exist?(collection_file_name)).to be_falsey
    end

    it "validates the class list" do
      expect { actor.call([GenericFile, Collection, String]) }.to raise_error(Sufia::Export::RegistryError)
    end

    context "with multiple files" do
      let!(:file2) { create :generic_file }
      let!(:file3) { create :generic_file }
      let(:generic_file2_file_name) { "tmp/export/generic_file_#{file2.id}.json" }
      let(:generic_file3_file_name) { "tmp/export/generic_file_#{file3.id}.json" }
      it "limits by id" do
        expect { actor.call([GenericFile, Collection], ids: [file2.id, file3.id]) }.not_to raise_error
        expect(File.exist?(generic_file2_file_name)).to be_truthy
        expect(File.exist?(generic_file3_file_name)).to be_truthy
        expect(File.exist?(generic_file_file_name)).to be_falsey
        expect(File.exist?(collection_file_name)).to be_falsey
      end

      it "limits by id and number" do
        expect { actor.call([GenericFile, Collection], ids: [file2.id, file3.id], limit: 1) }.not_to raise_error
        expect(File.exist?(generic_file2_file_name)).to be_truthy
        expect(File.exist?(generic_file3_file_name)).to be_falsey
        expect(File.exist?(generic_file_file_name)).to be_falsey
        expect(File.exist?(collection_file_name)).to be_falsey
      end
    end
  end
end
