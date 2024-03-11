# frozen_string_literal: true

require "yaml"
require "erb"
require "debug"

# NOTE: These requires are for using some methods in a config file.
require "securerandom"
require "json"

class DummyOscar::App
  private_class_method :new

  class << self
    def build(config_file)
      new(config_file)
    end
  end

  def initialize(config_file)
    @routing = {}
    parse_config_file(config_file)
  end

  def app(env)
    $stdout.puts "Started #{env["REQUEST_METHOD"]} #{env["PATH_INFO"]}"

    route = @routing.dig(env["PATH_INFO"], env["REQUEST_METHOD"].downcase)
    if route
      headers = {}
      headers["Content-Type"] = route["content_type"] if route["content_type"]
      return [route["status_code"], headers, [route["body"].to_s]]
    end

    [404, {}, ["Not found"]]
  end

  private

  def parse_config_file(config_file)
    source = ERB.new(File.read(config_file)).result(binding)
    config = YAML.load(source)
    config["paths"].each do |path, list|
      @routing[path] = {}
      list.each do |method, response|
        raise DummyOscar::ParseConfigError, "You need to specify `:response` in the config file." if response["response"].nil?
        @routing[path][method.downcase] = response["response"]
      end
    end
  end
end
