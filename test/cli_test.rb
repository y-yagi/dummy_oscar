# frozen_string_literal: true

require "test_helper"

class CliTest < Minitest::Test
  def test_parse_without_argv
    assert_raises(OptionParser::MissingArgument) { DummyOscar::Cli.new(["s"]).parse }
  end

  def test_parse_with_argv
    cli = DummyOscar::Cli.new(["s", "-C", "test/fixtures/basic.yml", "-p", "3000", "-r", "library.rb"])
    options = cli.parse
    assert_equal options[:config], "test/fixtures/basic.yml"
    assert_equal options[:port], 3000
    assert_equal options[:library], "library.rb"
  end
end
