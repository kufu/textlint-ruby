# frozen_string_literal: true

require 'ripper'

module Textlint
  class Parser
    class RubyToTextlintAST < ::Ripper::Filter
      EVENT_RE = /\Aon_(?<name>\w*)_(?:beg|end)\z/.freeze

      # @param src [String]
      # @param lines [Array<String>]
      def initialize(src)
        super(src)
        @src = src
        @pos = 0
        @lines = @src.lines
        @events = []
      end

      private

      # All events call this method
      # NOTE: Instance variables are allowed to assign only here to readable code.
      def on_default(event, token, node)
        @token = token
        @event = event

        method_name = :"custom_#{event}"

        if respond_to?(method_name, true)
          @range = @pos...(@pos + @token.size)
          @raw = @src[@range]
          send(method_name, node)
        end

        @pos += @token.size

        node
      end

      def default_node_attributes(type:, **attributes)
        break_count = @token.scan(Textlint::BREAK_RE).size

        last_column = if break_count == 0
                        column + @token.size
                      else
                        @token.match(LAST_LINE_RE).to_s.size
                      end

        {
          type: type,
          raw: @raw,
          range: @range,
          loc: Textlint::Nodes::TxtNodeLineLocation.new(
            start: Textlint::Nodes::TxtNodePosition.new(
              line: lineno,
              column: column
            ),
            end: Textlint::Nodes::TxtNodePosition.new(
              line: lineno + break_count,
              column: last_column
            )
          )
        }.merge(attributes)
      end

      # "hello world"
      # 'hello world'
      # %q{hello world}
      def custom_on_tstring_content(parentNode)
        begin_event_name, _begin_node = @events.last
        return unless %w[tstring qwords].include?(begin_event_name)

        node = Textlint::Nodes::TxtTextNode.new(
          **default_node_attributes(
            type: Textlint::Nodes::STR,
            value: @token
          )
        )

        parentNode.children.push(node)

        parentNode
      end

      # # hello world
      def custom_on_comment(parentNode)
        node = Textlint::Nodes::TxtTextNode.new(
          **default_node_attributes(
            type: Textlint::Nodes::COMMENT,
            value: @token.gsub(/\A#/, '')
          )
        )

        parentNode.children.push(node)
      end

      # =begin
      # hello world
      # =end
      def custom_on_embdoc(parentNode)
        _begin_event_name, begin_node = @events.last

        node = Textlint::Nodes::TxtTextNode.new(
          type: Textlint::Nodes::COMMENT,
          loc: begin_node.loc,
          range: begin_node.range,
          raw: begin_node.raw,
          value: @token
        )

        parentNode.children.push(node)
      end

      def event_name
        matched = EVENT_RE.match(@event)
        matched[:name] if matched
      end

      def on_beg_event(*)
        @events.push(
          [
            event_name,
            Textlint::Nodes::TxtTextNode.new(
              **default_node_attributes(
                type: nil, # NOTE: beg event has no type
                value: @token
              )
            )
          ]
        )
      end

      def on_end_event(*)
        @events.pop
      end

      alias custom_on_tstring_beg on_beg_event
      alias custom_on_regexp_beg on_beg_event
      alias custom_on_embexpr_beg on_beg_event
      alias custom_on_qwords_beg on_beg_event
      alias custom_on_embdoc_beg on_beg_event

      alias custom_on_tstring_end on_end_event
      alias custom_on_regexp_end on_end_event
      alias custom_on_embexpr_end on_end_event
      alias custom_on_embdoc_end on_end_event
    end

    # Parse ruby code to AST for textlint
    #
    # @param src [String]
    #
    # @return [Textlint::Nodes::TxtParentNode]
    def self.parse(src)
      new(src).call
    end

    # @param src [String] ruby source code
    def initialize(src)
      @src = src
    end

    # Parse ruby code to AST for textlint
    #
    # @return [Textlint::Nodes::TxtParentNode]
    def call
      check_syntax!

      document = Textlint::Nodes::TxtParentNode.new(
        type: Textlint::Nodes::DOCUMENT,
        raw: @src,
        range: 0...@src.size,
        loc: Textlint::Nodes::TxtNodeLineLocation.new(
          start: Textlint::Nodes::TxtNodePosition.new(
            line: 1,
            column: 0
          ),
          end: Textlint::Nodes::TxtNodePosition.new(
            line: @src.split(Textlint::BREAK_RE).size + 1,
            column: @src.match(LAST_LINE_RE).to_s.size # extract last line
          )
        )
      )

      RubyToTextlintAST.new(@src).parse(document)
    end

    private

    def check_syntax!
      RubyVM::InstructionSequence.compile(@src)
    rescue ::SyntaxError => error
      raise Textlint::SyntaxError, error.message
    end
  end
end
