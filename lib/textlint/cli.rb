# frozen_string_literal: true

require 'optparse'

module Textlint
  class Cli
    attr_reader :options

    DEFAULT_OPTIONS = {
      stdio: false,
      paths: []
    }.freeze

    # @param argv [Array] ARGV
    def self.run(argv)
      new(argv).run
    end

    # @param argv [Array] ARGV
    def initialize(argv)
      @options = DEFAULT_OPTIONS.dup
      parse_options(argv)
    end

    # Run textlint-ruby
    #
    # @return [void]
    def run
      if @options[:stdio]
        run_stdio_server
      else
        run_file_parser
      end
    end

    private

    def run_stdio_server
      Textlint::Server.new.start
    end

    def run_file_parser
      path = @options[:path]

      unless File.exist?(path.to_s)
        warn("Error: No such file or directory: #{path}")
        exit(1)
      end

      content = File.read(path)

      begin
        ast = Textlint::Parser.parse(content)
        puts(ast.as_textlint_json.to_json)
      rescue Textlint::SyntaxError => error
        warn("Failed to compile: #{path}")
        warn('')
        warn(error)
        exit(1)
      end
    end

    def parse_options(argv)
      option_parser = ::OptionParser.new do |parser|
        parser.banner = 'Usage: textlint-ruby [rubyfile_path] [options]'
        parser.program_name = 'textlint-ruby'

        parser.version = [
          Textlint::VERSION::MAJOR,
          Textlint::VERSION::MINOR,
          Textlint::VERSION::TINY
        ]

        parser.on('--stdio', 'use stdio') do
          @options[:stdio] = true
        end

        parser.on_tail('-h', '--help') do
          puts option_parser.help
          exit
        end
      end

      @options[:path] = option_parser.parse(argv).first

      if !@options[:stdio] && !@options[:path]
        puts option_parser.help
        exit(1)
      end
    end
  end
end
