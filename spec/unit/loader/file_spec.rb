require 'dry/system/loader'
require 'pathname'

RSpec.describe Dry::System::Loader::File do
  before(:all) { $LOAD_PATH.unshift(Pathname.new(__dir__).join('fixtures').realpath) }

  let(:base_dir) { Pathname.new(__dir__).join('fixtures') }
  let(:loader) { described_class.new(base_dir, Pathname.new('test/foo'), {an_option: true}) }

  describe '#call' do
    let!(:instancer) { loader.call }

    it 'requires the file' do
      expect(Kernel.const_defined?('Test::Foo')).to be(true)
    end

    it 'returns an instance proc' do
      expect(instancer.call).to be_a(Test::Foo)
    end
  end

  describe '#[]' do
    it 'returns the options value' do
      expect(loader[:an_option]).to be(true)
    end
  end
end
