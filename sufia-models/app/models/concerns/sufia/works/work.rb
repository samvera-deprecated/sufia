# The base class of all works
module Sufia::Works
  module Work
    extend ActiveSupport::Concern

    include Sufia::Works::CurationConcern::Work

  end
end
