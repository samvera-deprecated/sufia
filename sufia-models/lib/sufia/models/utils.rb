module Sufia
  module Utils
    extend ActiveSupport::Concern

    def retry_unless(number_of_tries, condition, &block)
      self.class.retry_unless(number_of_tries, condition, &block)
    end

    module ClassMethods
      def retry_unless(number_of_tries, condition, &block)
        raise ArgumentError, "First argument must be an enumerator" unless number_of_tries.is_a? Enumerator
        raise ArgumentError, "Second argument must be a lambda" unless condition.respond_to? :call
        raise ArgumentError, "Must pass a block of code to retry" unless block_given?
        number_of_tries.each do
          result = block.call
          return result unless condition.call
        end
        raise RuntimeError, "retry_unless could not complete successfully. Try upping the # of tries?"
      end
    end
  end
end
