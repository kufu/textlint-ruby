# frozen_string_literal: true

require 'stringio'

RSpec.describe Textlint::Server do
  describe 'InstanceMethods' do
    shared_context 'server' do
      let(:server) do
        described_class.new(
          stdin: stdin,
          stdout: stdout,
          stderr: stderr
        )
      end

      let(:stdin) do
        StringIO.new
      end

      let(:stdout) do
        StringIO.new
      end

      let(:stderr) do
        StringIO.new
      end

      let(:request_base) do
        { seq: 1, version: described_class::REQUIRED_VERSION }
      end

      def request(hash)
        pos = stdin.pos
        stdin.puts(JSON.dump(hash))
        stdin.seek(pos)
      end

      def receive_io(io, &block)
        pos = io.pos
        block.call
        io.seek(pos)
        io.read
      end
    end

    describe '#start' do
      include_context 'server'

      subject(:start_server) do
        -> { server.start }
      end

      context 'given invalid requst' do
        subject do
          request(message)
          receive_io(stderr) { start_server.call }
        end

        describe 'version' do
          let(:version_error) do
            "textlint-ruby requires textlin-plugin-ruby version >= #{described_class::REQUIRED_VERSION}\n"
          end

          context 'given blank' do
            let(:message) do
              {}
            end

            it { is_expected.to eq(version_error) }
          end

          context 'smaller than required version' do
            let(:message) do
              { version: '1.9.9' }
            end

            it { is_expected.to eq(version_error) }
          end

          context 'greater than or equal to required version' do
            let(:message) do
              { version: described_class::REQUIRED_VERSION }
            end

            it { is_expected.to_not eq(version_error) }
          end
        end

        describe 'action' do
          context 'given unknown action' do
            let(:message) do
              { version: described_class::REQUIRED_VERSION, action: 'unknown' }
            end

            it { is_expected.to eq(%{Unknown action(unknown) given. Available actions are #{described_class::AVAILABLE_ACTIONS}\n}) }
          end
        end

        describe 'json' do
          context 'given invalid json' do
            it do
              stdin.puts('{} {}')
              stdin.rewind
              message = receive_io(stderr) { start_server.call }

              expect(message).to eq("Can't parse request to JSON\n")
            end
          end
        end
      end

      context 'do_info' do
        it 'returns version' do
          request(request_base.merge(action: 'info'))
          message = receive_io(stdout) { start_server.call }
          json = JSON.parse(message)

          expect(json).to eq({ 'request_seq' => 1, 'result' => Textlint::VERSION::STRING })
        end
      end

      context 'do_parse' do
        let(:ruby_path) do
          File.expand_path('../samples/comment.rb', __dir__)
        end

        let(:json_path) do
          File.expand_path('../samples/comment.json', __dir__)
        end

        it 'returns parsed AST' do
          request(request_base.merge(action: 'parse', path: ruby_path))
          message = receive_io(stdout) { start_server.call }
          json = JSON.parse(message)

          expect(json).to eq({ 'request_seq' => 1, 'result' => JSON.parse(File.read(json_path)) })
        end
      end
    end
  end
end
