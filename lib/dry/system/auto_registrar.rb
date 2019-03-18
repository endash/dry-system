module Dry
  module System
    class AutoRegistrar
      PATH_SEPARATOR = '/'

      attr_reader :loader, :default_namespace, :namespace_separator

      def initialize(loader:, default_namespace:, namespace_separator: '.')
        @loader = loader
        @default_namespace = default_namespace
        @namespace_separator = namespace_separator
      end

      def call(container, *args)
        loader.call(*args).map do |file|
          key = key_for(file.name)

          next if container.key?(key)
          next if file[:auto_register] == false

          file.call do |instance|
            container.register(key, memoize: file[:memoize]) do
              block_given? ? yield(instance) : instance.call
            end
          end
        end
      end

      def key_for(name)
        key = name.split(PATH_SEPARATOR).map(&:to_sym)

        if default_namespace && key.first(default_namespace.size) == default_namespace
          key = key.drop(default_namespace.size)
        end

        key.join(namespace_separator)
      end
    end
  end
end
