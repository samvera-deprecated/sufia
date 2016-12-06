require 'rails_helper'

describe Qa::Authorities::Local::FindWorks do
  subject { described_class.new(q: "Query") }

  describe "#properties" do
    it { is_expected.to respond_to("q") }
    it { is_expected.to respond_to("search") }
  end
end
