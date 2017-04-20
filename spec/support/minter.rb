RSpec.configure do |config|
  # An in memory id minter, which mints IDs 9 digits wide
  # This is not threadsafe and not persistent, so it is only
  # sutiable for testing.
  class TestMinter
    MAX = 10_000_000
    def initialize
      @state = (rand * MAX).round
    end

    def mint
      @state += 1
      format("xx%07i", @state % MAX)
    end
  end

  config.before(:suite) do
    ActiveFedora::Noid.configure do |noid_config|
      noid_config.minter_class = TestMinter
    end
  end
end
