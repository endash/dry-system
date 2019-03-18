require 'dry/system/loader'
require 'pathname'

RSpec.describe Dry::System::Loader do
  before(:all) { $LOAD_PATH.unshift(Pathname.new(__dir__).join('fixtures').realpath) }

  let(:loader) { described_class.new }
  let(:base_dir) { Pathname.new(__dir__).join('fixtures') }

  describe '#call' do
    let!(:loaders) { loader.call(base_dir) }

    it 'returns an array' do
      expect(loaders).to be_a(Array)
      expect(loaders.size).to eq(2)
    end

    it 'does not actually require anything' do
      expect(Kernel.const_defined?('Test::Foo')).to be(false)
    end

    it 'parses magic comments' do
      expect(loaders.first[:auto_load]).to be(false)
      expect(loaders.last[:valid_comment]).to eq('hello')
    end
  end

  describe '#call!' do
    let!(:loaders) { loader.call!(base_dir) }

    it 'actually requires the files' do
      expect(Kernel.const_defined?('Test::Foo')).to be(true)
    end

    it 'does not require files that are auto_load: false' do
      expect(Kernel.const_defined?('Test::AutoLoadFalse')).to be(false)
    end
  end
end
