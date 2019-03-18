module Dry
  module System
    class Loader
      class File
        attr_reader :base_dir, :file, :options, :require_strategy, :instance_factory

        def initialize(base_dir, file, options, require_strategy: Require, instance_factory: Instance.new)
          @base_dir = base_dir
          @file = file
          @options = options
          @require_strategy = require_strategy
          @instance_factory = instance_factory
        end

        def [](key)
          options[key]
        end

        def name
          @name ||= file.to_s.gsub('.rb', '')
        end

        def call
          require_strategy.call(name)
          instance_callable = instance_factory.call(name)

          if block_given?
            yield(instance_callable)
          else
            instance_callable
          end
        end
      end
    end
  end
end
