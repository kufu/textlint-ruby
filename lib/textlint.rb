# frozen_string_literal: true

require 'json'
require 'textlint/version'
require 'textlint/nodes'
require 'textlint/parser'
require 'textlint/cli'
require 'textlint/server'

module Textlint
  BREAK_RE = /\r?\n/.freeze
  LAST_LINE_RE = /(?!\r?\n).*\z/.freeze

  class Error < StandardError; end
  class SyntaxError < Error; end
  class RequestError < Error; end
end
