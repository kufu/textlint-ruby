# frozen_string_literal: true

require 'ripper'

module Textlint
  class Parser
    class RubyToTextlintAST < ::Ripper::Filter
      # @param src [String]
      # @param lines [Array<String>]
      def initialize(src)
        super(src)
        @src = src
        @pos = 0
        @lines = @src.lines
        @begins = Hash.new { |h, k| h[k] = [] }
      end

      private

      # NOTE: Instance variables are allowed to assign only here to readable code.
      def on_default(event, token, node)
        @token = token
        @range = Textlint::Nodes::TxtNodeRange.new(@pos, @pos + @token.size, exclude_end: true)
        @raw = @src[@range]

        method_name = :"custom_#{event}"
        node = send(method_name, node) if respond_to?(method_name, true)

        @pos += @token.size

        node
      end

      def custom_on_comment(parentNode)
        node = Textlint::Nodes::TxtTextNode.new(
          type: Textlint::Nodes::COMMENT,
          raw: @raw,
          range: @range,
          value: @token.gsub(/\A#/, ''),
          loc: Textlint::Nodes::TxtNodeLineLocation.new(
            start: Textlint::Nodes::TxtNodePosition.new(
              line: lineno,
              column: column
            ),
            end: end_txt_node_position
          )
        )

        parentNode.children.push(node)
        parentNode
      end

      # Start embedded document
      # =begin
      def custom_on_embdoc_beg(parentNode)
        @begins['on_embdoc'].push(
          begin_range: @range,
          begin_location: Textlint::Nodes::TxtNodePosition.new(
            line: lineno,
            column: column
          ),
          tokens: []
        )

        parentNode
      end

      # embedded document within start~end
      # =begin   | custom_on_embdoc_beg
      # <-here   | custom_on_embdoc
      # <-here   | custom_on_embdoc
      # =end     | custom_on_embdoc_end
      def custom_on_embdoc(parentNode)
        @begins['on_embdoc'].last[:tokens].push(@token)
        parentNode
      end

      # End embedded document
      # =end
      def custom_on_embdoc_end(parentNode)
        embdoc = @begins['on_embdoc'].pop

        range = Textlint::Nodes::TxtNodeRange.new(
          embdoc[:begin_range].begin,
          @range.end,
          exclude_end: true
        )

        node = Textlint::Nodes::TxtTextNode.new(
          type: Textlint::Nodes::COMMENT,
          raw: @src[range],
          range: range,
          value: embdoc[:tokens].join,
          loc: Textlint::Nodes::TxtNodeLineLocation.new(
            start: embdoc[:begin_location],
            end: end_txt_node_position
          )
        )

        parentNode.children.push(node)
        parentNode
      end

      def line_location; end

      def end_txt_node_position
        break_count = @token.scan(Textlint::BREAK_RE).size

        last_column = if break_count == 0
                        column + @token.size
                      else
                        @token.match(LAST_LINE_RE).to_s.size
                      end

        Textlint::Nodes::TxtNodePosition.new(
          line: lineno + break_count,
          column: last_column
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
      document = Textlint::Nodes::TxtParentNode.new(
        type: Textlint::Nodes::DOCUMENT,
        raw: @src,
        range: Textlint::Nodes::TxtNodeRange.new(0, @src.size, exclude_end: true),
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
  end
end
