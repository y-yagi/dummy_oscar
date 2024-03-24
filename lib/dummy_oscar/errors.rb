# frozen_string_literal: true

module DummyOscar
  class Error < StandardError; end
  class ParseConfigError < Error; end
  class ArgumentError < Error; end
end
