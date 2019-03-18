require 'pathname'
require 'rake/file_list'
require 'dry/inflector'

require 'dry/system/loader/file'
require 'dry/system/loader/require'
require 'dry/system/loader/instance'
require 'dry/system/magic_comments_parser'

module Dry
  module System
    class Loader
      extend Dry::Configurable

      setting :root, Object
      setting :require_strategy, Require
      setting :instance_factory, Instance
      setting :inflector, Dry::Inflector.new

      def config
        self.class.config
      end

      def instance_factory
        @instance_factory ||= config.instance_factory.new(config.inflector, root: config.root)
      end

      def call(base_dir, file_or_pattern = '**/*.rb', except: nil, **options)
        base_dir = Pathname.new(base_dir)

        files = Rake::FileList.new(base_dir.join(file_or_pattern)).exclude(*Array(except))

        Array(files).map do |file|
          file = Pathname.new(file)
          file = file.relative_path_from(base_dir) rescue file
          self.for(base_dir, file, options)
        end
      end

      def call!(*args)
        call(*args).map do |file|
          next if file[:auto_load] == false
          file.call
        end
      end

      def for(base_dir, file = nil, options)
        options = MagicCommentsParser.call(base_dir.join(file)).merge(options)

        File.new(
          base_dir, file, options,
          require_strategy: config.require_strategy,
          instance_factory: instance_factory
        )
      end
    end
  end
end
