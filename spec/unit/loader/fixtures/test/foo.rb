# valid_comment: hello

module Test
  class Foo
    attr_reader :name
    def initialize(name = 'Alice')
      @name = name
    end
  end
end
