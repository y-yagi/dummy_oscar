# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "dummy_oscar"
require "debug"

require "minitest/hooks/test"
require "minitest/autorun"
