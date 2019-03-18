module Dry
  module System
    class Loader
      Require = Proc.new do |name|
        require(name)
      end
    end
  end
end
