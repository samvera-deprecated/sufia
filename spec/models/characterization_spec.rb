require 'spec_helper'

describe Sufia::GenericFile::Characterization do
  before do
    class TestClass < ActiveFedora::Base
      include Sufia::GenericFile::Characterization

      has_file_datastream 'content', type: FileContentDatastream
      attr_accessor :title, :creator
    end
  end

  after do
    Object.send(:remove_const, :TestClass)
  end

  subject { TestClass.new }

  it "should not depend on anything except a file datastream and some property accessors" do
    expect { subject.characterize }.to_not raise_error
  end

end
