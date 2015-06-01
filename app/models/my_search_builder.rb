# Added to allow for the My controller to show only things I have edit access to
class MySearchBuilder < Blacklight::SearchBuilder
  include Sufia::MySearchBuilderBehavior
end
