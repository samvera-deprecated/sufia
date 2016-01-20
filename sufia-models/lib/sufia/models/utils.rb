# This module includes utility methods
module Sufia
  module Utils
    extend ActiveSupport::Concern

    # retry the block if the conditional call is true unless we hit the maximum tries
    #
    # @param number_of_tries [enumerator] maximum number of times to retry the block (eg. 7.times)
    # @param condition [#call] conditional to call and see if we SHOULD retry
    # @yeild block [] code you want to run and retry
    #
    # @return result of the block call
    def retry_unless(number_of_tries, condition, &block)
      self.class.retry_unless(number_of_tries, condition, &block)
    end

    module ClassMethods
      # retry the block if the conditional call is true unless we hit the maximum tries
      #
      # @param number_of_tries [enumerator] maximum number of times to retry the block
      # @param condition [#call] conditional to call and see if we SHOULD retry
      # @yeild block [] code you want to run and retry
      #
      # @return result of the block call
      def retry_unless(number_of_tries, condition, &_block)
        raise ArgumentError, "First argument must be an enumerator" unless number_of_tries.is_a? Enumerator
        raise ArgumentError, "Second argument must be a lambda" unless condition.respond_to? :call
        raise ArgumentError, "Must pass a block of code to retry" unless block_given?
        number_of_tries.each do
          result = yield
          return result unless condition.call
          sleep(Sufia.config.retry_unless_sleep) if Sufia.config.retry_unless_sleep > 0
        end
        raise "retry_unless could not complete successfully. Try upping the # of tries?"
      end
    end
  end
end
