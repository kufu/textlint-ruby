# frozen_string_literal: true

require 'json'
require 'textlint/version'
require 'textlint/nodes'
require 'textlint/parser'

module Textlint
  BREAK_RE = /\r?\n/.freeze
  LAST_LINE_RE = /(?!\r?\n).*\z/.freeze

  class SyntaxError < StandardError; end
end
