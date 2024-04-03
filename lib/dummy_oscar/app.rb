# frozen_string_literal: true

require "yaml"
require "erb"

# NOTE: These requires are for using some methods in a config file.
require "securerandom"
require "json"

class DummyOscar::App
  private_class_method :new

  class << self
    def build(config_file, library:)
      new(config_file, library: library)
    end
  end

  def initialize(config_file, library:)
    @router = DummyOscar::Router.new
    parse_config_file(config_file, library: library)
  end

  def app(env)
    input = "'#{env['rack.input'].read}'"
    $stdout.puts "Started #{env["REQUEST_METHOD"]} #{env["PATH_INFO"]} #{input}"

    route = @router.find(path: env["PATH_INFO"], method: env["REQUEST_METHOD"])
    if route
      headers = {}
      headers["Content-Type"] = route.response["content_type"] if route.response["content_type"]
      return [route.response["status_code"], headers, [route.response["body"].to_s]]
    end

    [404, {}, ["Not found"]]
  end

  private

  def parse_config_file(config_file, library:)
    require(library) if library

    source = ERB.new(File.read(config_file)).result(binding)
    config = YAML.load(source)
    config["paths"].each do |path, list|
      list.each do |method, response|
        raise DummyOscar::ParseConfigError, "You need to specify `:response` in the config file." if response["response"].nil?
        @router.add(path: path, method: method, response: response["response"])
      end
    end
  end
end
