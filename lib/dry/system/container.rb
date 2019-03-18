require 'dry-configurable'
require 'dry/container/mixin'

require 'dry/system/loader'
require 'dry/system/auto_registrar'

module Dry
  module System
    class Container
      extend Dry::Configurable
      extend Dry::Container::Mixin

      setting :name
      setting :default_namespace
      setting(:root, Pathname.pwd.freeze) { |path| Pathname(path) }, reader: true

      setting :loader, Dry::System::Loader.new, reader: true
      setting :auto_registrar, Dry::System::AutoRegistrar

      class << self
        def default_namespace
          @default_namespace ||= config.default_namespace.to_s.split(config.namespace_separator).map(&:to_sym)
        end

        def auto_registrar
          @auto_registrar ||= config.auto_registrar.new(
            loader: loader,
            default_namespace: config.default_namespace,
            namespace_separator: config.namespace_separator
          )
        end

        def auto_register(dirs, *args, **options)
          Array(dirs).map do |dir|
            auto_registrar.call(self, root.join(dir), *args, **options)
          end
        end
      end
    end
  end
end
