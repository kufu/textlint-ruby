# frozen_string_literal: true

require 'ripper'

module Textlint
  class Parser
    class RubyToTextlintAST < ::Ripper::Filter
      # @param src [String]
      # @param lines [Array<String>]
      def initialize(src, lines)
        super(src)
        @src = src
        @pos = 0
        @lines = lines
      end

      private

      # NOTE: Instance variables are allowed to change only here to readable code.
      def on_default(event, token, parentNode)
        @token = token
        @range = Textlint::Nodes::TxtNodeRange.new(@pos, @pos + @token.size)
        @raw = @src[@range]

        method_name = :"custom_#{event}"
        send(method_name, parentNode) if respond_to?(method_name, true)

        @pos += @token.size

        parentNode
      end

      def custom_on_comment(parentNode)
        node = Textlint::Nodes::TxtTextNode.new(
          type: Textlint::Nodes::COMMENT,
          raw: @raw,
          range: @range,
          loc: line_location,
          value: @token
        )

        parentNode.children.push(node)
        parentNode
      end

      def line_location
        break_count = [@token.scan(Textlint::BREAK_RE).size - 1, 0].max
        @raw.split(Textlint::BREAK_RE)

        Textlint::Nodes::TxtNodeLineLocation.new(
          start: Textlint::Nodes::TxtNodePosition.new(
            line: lineno,
            column: column
          ),
          end: Textlint::Nodes::TxtNodePosition.new(
            line: lineno + break_count,
            column: column + @token.size # TODO: Support multiline
          )
        )
      end

      # def on_tstring_beg(tok, f)
      #   f << %(<span class="string">#{CGI.escapeHTML(tok)})
      # end
      #
      # def on_tstring_end(tok, f)
      #   f << %(#{CGI.escapeHTML(tok)}</span>)
      # end
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
      lines = @src.split(Textlint::BREAK_RE)

      document = Textlint::Nodes::TxtParentNode.new(
        type: Textlint::Nodes::DOCUMENT,
        raw: @src,
        range: Textlint::Nodes::TxtNodeRange.new(0, @src.size),
        loc: Textlint::Nodes::TxtNodeLineLocation.new(
          start: Textlint::Nodes::TxtNodePosition.new(
            line: 1,
            column: 0
          ),
          end: Textlint::Nodes::TxtNodePosition.new(
            line: [@src.split(Textlint::BREAK_RE).size, 1].max,
            column: lines.last.to_s.length
          )
        )
      )

      RubyToTextlintAST.new(@src, lines).parse(document)
    end
  end
end
