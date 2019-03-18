require 'dry/container'
require 'dry/system/loader'
require 'dry/system/auto_registrar'

RSpec.describe Dry::System::AutoRegistrar do
  before(:all) do
    $LOAD_PATH.unshift(Pathname.new(__dir__).join('fixtures/components').realpath.to_s)
    $LOAD_PATH.unshift(Pathname.new(__dir__).join('fixtures/namespaced_components').realpath.to_s)
    $LOAD_PATH.unshift(Pathname.new(__dir__).join('fixtures/multiple_namespaced_components').realpath.to_s)
  end

  let(:container) { Dry::Container.new }
  let(:root) { Pathname.new(__dir__).join('fixtures') }
  let(:default_namespace) { :test }
  let(:dir) { 'components' }
  let(:options) { {} }

  subject(:auto_registrar) do
    described_class.new(loader: Dry::System::Loader.new, default_namespace: default_namespace && Array(default_namespace))
  end

  describe '#call' do
    before do
      auto_registrar.call(container, root.join(dir), **options)
    end

    specify do
      expect(container['foo']).to be_an_instance_of(Foo)
      expect(container['bar']).to be_an_instance_of(Bar)
    end

    it "doesn't register files with inline option 'auto_register: false'" do
      expect(container.key?('no_register')).to be(false)
    end

    describe 'pattern' do
      let(:options) { {pattern: '**/foo*'} }

      specify { expect(container.keys).to include(*%w{foo}) }
    end

    describe 'except' do
      context 'with a regexp' do
        let(:options) { {except: /bar/} }

        it 'excludes any file matching bar' do
          expect(container.keys).to include(*%w{foo})
        end
      end

      context 'with a glob' do
        let(:options) { {except: '**/bar/*'} }

        it 'excludes just bar/baz' do
          expect(container.keys).to include(*%w{bar foo})
        end
      end

      context 'with multiple patterns' do
        let(:options) { {except: [/foo/, /bar/]} }

        it 'excludes all the files' do
          expect(container.keys).not_to include(*%w{foo bar})
        end
      end
    end

    describe 'memoize' do
      context 'true' do
        let(:options) { {memoize: true} }

        specify do
          expect(container['foo']).to be_an_instance_of(Foo)
          expect(container['foo']).to be(container['foo'])
        end
      end

      context 'false' do
        let(:options) { {memoize: false} }

        specify do
          expect(container['foo']).to be_an_instance_of(Foo)
          expect(container['foo']).not_to be(container['foo'])
        end
      end
    end

    context 'with a default namespace' do
      let(:default_namespace) { :namespaced }

      context 'files nested in directory of same name' do
        let(:dir) { 'namespaced_components' }

        specify do
          expect(container['bar']).to be_a(Namespaced::Bar)
          expect(container['foo']).to be_a(Namespaced::Foo)
        end
      end

      context 'files are not nested in directory of same name' do
        let(:dir) { 'components' }

        specify do
          expect(container['foo']).to be_an_instance_of(Foo)
          expect(container['bar']).to be_an_instance_of(Bar)
          expect(container['bar.baz']).to be_an_instance_of(Bar::Baz)
        end
      end

      context 'nested default namespace' do
        let(:default_namespace) { [:multiple, :level] }
        let(:dir) { 'multiple_namespaced_components' }

        specify do
          expect(container['baz']).to be_a(Multiple::Level::Baz)
          expect(container['foz']).to be_a(Multiple::Level::Foz)
        end
      end
    end
  end
end
