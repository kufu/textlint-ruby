# frozen_string_literal: true

RSpec.describe Textlint::Cli do
  describe 'InstanceMethods' do
    describe '#initialize' do
      subject(:cli) do
        described_class.new(argv)
      end

      context 'given path' do
        let(:argv) do
          ['path']
        end

        it 'parses options' do
          expect(cli.options[:path]).to eq('path')
        end
      end

      context 'given --stdio' do
        let(:argv) do
          ['--stdio']
        end

        it 'parses options' do
          expect(cli.options[:stdio]).to be(true)
        end
      end
    end

    describe '#run' do
      subject do
        -> { described_class.new(argv).run }
      end

      context 'without --stdio' do
        let(:argv) do
          [ruby_file]
        end

        let(:ruby_file) do
          File.expand_path('../samples/blank.rb', __dir__)
        end

        it 'parses file' do
          is_expected.to output(/Document/).to_stdout
        end
      end
    end
  end
end
