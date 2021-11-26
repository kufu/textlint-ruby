# frozen_string_literal: true

RSpec.describe Textlint::Parser do
  describe 'ClassMethods' do
    describe '.parse' do
      subject(:parsed) do
        described_class.parse(src)
      end

      describe 'samples' do
        sample_directory = File.expand_path('../samples', __dir__)
        sample_files = Dir["#{sample_directory}/**/*.rb"]

        debug_path = nil
        # debug_path = '/Users/alpaca-tc/projects/alpaca-tc/textlint-ruby/spec/samples/multiline_comment.rb'
        sample_files.reject { _1 != debug_path if debug_path }.each do |rb_file_path|
          describe "parsed #{rb_file_path}" do
            let(:src) do
              File.read(rb_file_path)
            end

            let(:expected_json_path) do
              rb_file_path.sub(/\.rb$/, '.json')
            end

            let(:expected_json) do
              JSON.parse(File.read(expected_json_path))
            end

            it 'returns expected json' do
              is_expected.to be_a(Textlint::Nodes::TxtParentNode)

              stringified = parsed.as_textlint_json.to_json

              expect(File.exist?(expected_json_path)).to be_truthy, -> {
                <<~MSG
                  Missing json file for test (#{expected_json_path})

                  Current output:
                  #{stringified}
                MSG
              }

              expect(JSON.parse(stringified)).to eq(expected_json)
            end
          end
        end
      end
    end
  end
end
