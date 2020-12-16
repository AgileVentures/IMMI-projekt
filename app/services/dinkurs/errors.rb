module Dinkurs
  module Errors
    class DinkursError < StandardError; end
    class InvalidKey < DinkursError; end
    class InvalidFormat < DinkursError; end
  end
end
