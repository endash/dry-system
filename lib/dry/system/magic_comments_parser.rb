module Dry
  module System
    class MagicCommentsParser
      VALID_LINE_RE = /^(#.*)?$/.freeze
      COMMENT_RE = /^#\s+(?<name>[A-Za-z]{1}[A-Za-z0-9_]+):\s+(?<value>.+?)$/.freeze

      COERCIONS = {
        'true' => true,
        'false' => false,
      }.freeze

      def self.call(file_name)
        {}.tap do |options|
          ::File.foreach(file_name) do |line|
            break unless line =~ VALID_LINE_RE

            if (comment = line.match(COMMENT_RE))
              options[comment[:name].to_sym] = coerce(comment[:value])
            end
          end
        end
      end

      private

      def self.coerce(value)
        COERCIONS.fetch(value) { value }
      end
    end
  end
end
