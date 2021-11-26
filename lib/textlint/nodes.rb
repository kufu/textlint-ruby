# frozen_string_literal: true

module Textlint
  # Clone nodes from [textlint/ast-node-types](https://github.com/textlint/textlint/blob/d4c5075b5a7bcbf875d7cee122de7dc5253d325e/packages/%40textlint/ast-node-types/src/index.ts)
  module Nodes
    DOCUMENT = 'Document'
    DOCUMENT_EXIT = 'Document:exit'
    PARAGRAPH = 'Paragraph'
    PARAGRAPH_EXIT = 'Paragraph:exit'
    BLOCK_QUOTE = 'BlockQuote'
    BLOCK_QUOTE_EXIT = 'BlockQuote:exit'
    LIST_ITEM = 'ListItem'
    LIST_ITEM_EXIT = 'ListItem:exit'
    LIST = 'List'
    LIST_EXIT = 'List:exit'
    HEADER = 'Header'
    HEADER_EXIT = 'Header:exit'
    CODE_BLOCK = 'CodeBlock'
    CODE_BLOCK_EXIT = 'CodeBlock:exit'
    HTML_BLOCK = 'HtmlBlock'
    HTML_BLOCK_EXIT = 'HtmlBlock:exit'
    HORIZONTAL_RULE = 'HorizontalRule'
    HORIZONTAL_RULE_EXIT = 'HorizontalRule:exit'
    COMMENT = 'Comment'
    COMMENT_EXIT = 'Comment:exit'
    STR = 'Str'
    STR_EXIT = 'Str:exit'
    BREAK = 'Break' # well-known Hard Break
    BREAK_EXIT = 'Break:exit' # well-known Hard Break
    EMPHASIS = 'Emphasis'
    EMPHASIS_EXIT = 'Emphasis:exit'
    STRONG = 'Strong'
    STRONG_EXIT = 'Strong:exit'
    HTML = 'Html'
    HTML_EXIT = 'Html:exit'
    LINK = 'Link'
    LINK_EXIT = 'Link:exit'
    IMAGE = 'Image'
    IMAGE_EXIT = 'Image:exit'
    CODE = 'Code'
    CODE_EXIT = 'Code:exit'
    DELETE = 'Delete'
    DELETE_EXIT = 'Delete:exit'

    TXT_NODE_TYPES = [
      DOCUMENT,
      DOCUMENT_EXIT,
      PARAGRAPH,
      PARAGRAPH_EXIT,
      BLOCK_QUOTE,
      BLOCK_QUOTE_EXIT,
      LIST_ITEM,
      LIST_ITEM_EXIT,
      LIST,
      LIST_EXIT,
      HEADER,
      HEADER_EXIT,
      CODE_BLOCK,
      CODE_BLOCK_EXIT,
      HTML_BLOCK,
      HTML_BLOCK_EXIT,
      HORIZONTAL_RULE,
      HORIZONTAL_RULE_EXIT,
      COMMENT,
      COMMENT_EXIT,
      STR,
      STR_EXIT,
      BREAK,
      BREAK_EXIT,
      EMPHASIS,
      EMPHASIS_EXIT,
      STRONG,
      STRONG_EXIT,
      HTML,
      HTML_EXIT,
      LINK,
      LINK_EXIT,
      IMAGE,
      IMAGE_EXIT,
      CODE,
      CODE_EXIT,
      DELETE,
      DELETE_EXIT
    ].freeze

    # export interface TxtNode {
    #   type: TxtNodeType;
    #   raw: string;
    #   range: TextNodeRange;
    #   loc: TxtNodeLineLocation;
    #   // parent is runtime information
    #   // Not need in AST
    #   // For example, top Root Node like `Document` has not parent.
    #   parent?: TxtNode;
    #
    #   [index: string]: any;
    # }
    class TxtNode
      attr_reader :type, :raw, :range, :loc

      # @param type [String]
      # @param raw [String]
      # @param range [Textlint::Nodes::TxtNodeRange]
      # @param loc [Textlint::Nodes::TxtNodeLineLocation]
      def initialize(type:, raw:, range:, loc:)
        @type = type
        @raw = raw
        @range = range
        @loc = loc
      end

      # @return [Hash]
      def as_textlint_json
        {
          type: type,
          raw: raw,
          range: range.as_textlint_json,
          loc: loc.as_textlint_json
        }
      end
    end

    # export interface TxtParentNode extends TxtNode {
    #   children: Array<TxtNode | TxtTextNode>;
    # }
    class TxtParentNode < TxtNode
      attr_reader :children

      # @param children [Array<Textlint::Nodes::TxtNode>]
      def initialize(children: [], **attributes)
        @children = children
        super(**attributes)
      end

      # @return [Hash]
      def as_textlint_json
        h = super
        h[:children] = children.map(&:as_textlint_json)
        h
      end
    end

    # export interface TxtNodeLineLocation {
    #   start: TxtNodePosition;
    #   end: TxtNodePosition;
    # }
    class TxtNodeLineLocation
      attr_reader :start, :end

      # @param start [Textlint::Nodes::TxtNodePosition]
      # @param end [Textlint::Nodes::TxtNodePosition]
      def initialize(start:, end:)
        @start = start
        @end = binding.local_variable_get(:end)
      end

      # @return [Hash]
      def as_textlint_json
        {
          start: start.as_textlint_json,
          end: self.end.as_textlint_json
        }
      end
    end

    # export type TextNodeRange = [number, number];
    class TxtNodeRange < ::Range
      # @return [Array<Integer, Integer>]
      def as_textlint_json
        [
          self.begin,
          (exclude_end? ? self.end : self.end - 1)
        ]
      end
    end

    # export interface TxtTextNode extends TxtNode {
    #   value: string;
    # }
    class TxtTextNode < TxtNode
      attr_reader :value

      # @param value [String]
      # @param attributes [Hash]
      def initialize(value:, **attributes)
        @value = value
        super(**attributes)
      end

      # @return [Hash]
      def as_textlint_json
        h = super
        h[:value] = value
        h
      end
    end

    # export interface TxtNodePosition {
    #   line: number; // start with 1
    #   column: number; // start with 0
    # }
    class TxtNodePosition
      attr_reader :line, :column

      # @param line [Integer]
      # @param column [Integer]
      def initialize(line:, column:)
        @line = line
        @column = column
      end

      # @return [Hash]
      def as_textlint_json
        {
          line: line,
          column: column
        }
      end
    end
  end
end
