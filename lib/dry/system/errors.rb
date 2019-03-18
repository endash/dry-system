module Dry
  module System
    # Error raised when a resolved component couldn't be found
    #
    # @api public
    ComponentLoadError = Class.new(StandardError) do
      def initialize(component)
        super("could not load component #{component.inspect}")
      end
    end
  end
end
