# frozen_string_literal: true

require 'json'

module Textlint
  class Server
    REQUIRED_VERSION = '2.0.0'

    AVAILABLE_ACTIONS = %w[
      parse
      info
    ].freeze

    # @param stdin [IO]
    # @param stdout [IO]
    # @param stderr [IO]
    def initialize(stdin: $stdin, stdout: $stdout, stderr: $stderr)
      @stdin = stdin
      @stdout = stdout
      @stderr = stderr
    end

    # Start stdio server
    #
    # @return [void]
    def start
      @stdout.sync = true
      trap_signals
      start_server
    end

    private

    def start_server
      receive_stdin do |json|
        action = json['action']
        result = send(:"do_#{action}", json)
        request_seq = json['seq']
        response = { request_seq: request_seq, result: result }

        @stdout.puts(JSON.dump(response))
      end
    end

    def validate_request(json)
      if Gem::Version.create(json['version'].to_s) < Gem::Version.create(REQUIRED_VERSION)
        raise(Textlint::RequestError, "textlint-ruby requires textlin-plugin-ruby version >= #{REQUIRED_VERSION}")
      elsif !AVAILABLE_ACTIONS.include?(json['action'])
        raise(Textlint::RequestError, "Unknown action(#{json['action']}) given. Available actions are #{AVAILABLE_ACTIONS}")
      end
    end

    # request spec
    #   { "seq": number, "action": string, "version": string, [key: string]: any }
    #
    # response spec
    #   action "info"
    #     { "request_seq": number, "version": string, result: string(version) }
    #
    #   action "parse"
    #     { "request_seq": number, "version": string, result: string(AST for textlint) }
    def receive_stdin
      loop do
        return if @stdin.eof?

        line = @stdin.readline

        begin
          json = JSON.parse(line)
          validate_request(json)
          yield(json)
        rescue JSON::JSONError
          warn("Can't parse request to JSON")
        rescue StandardError => error
          warn(error.message)
        end
      end
    end

    def warn(message)
      @stderr.puts(message)
    end

    def trap_signals
      ::Signal.trap(:SIGINT) do
        exit
      end
    end

    def do_info(_json)
      Textlint::VERSION::STRING
    end

    def do_parse(json)
      path = json['path'].to_s

      unless File.exist?(path)
        raise(Textlint::RequestError, "Error: No such file or directory: #{path}")
      end

      content = File.read(path)

      ast = begin
        Textlint::Parser.parse(content)
      rescue Textlint::SyntaxError
        error = Textlint::RequestError.new("Failed to parse: #{path}. syntax error or the file is incompatible with the ruby(#{RUBY_VERSION}) running textlint-ruby")
        warn(error)

        Textlint::Parser.build_document(content)
      end

      ast.as_textlint_json
    end
  end
end
