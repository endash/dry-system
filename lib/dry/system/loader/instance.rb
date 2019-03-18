module Dry
  module System
    class Loader
      class Instance
        attr_reader :inflector, :root

        def initialize(inflector = Dry::Inflector.new, root: Object)
          @inflector = inflector
          @root = root
        end

        def call(name)
          Proc.new do |*args|
            # const_get works the same as normal constant lookup, so if
            # `root` doesn't have a nested constant of the right name
            # it'll walk its ancestors until it finds one that does

            constant = root.const_get(inflector.camelize(name))

            method = :instance if constant.respond_to?(:instance)
            method = :new if constant.respond_to?(:new)

            constant.send(method, *args)
          end
        end
      end
    end
  end
end
