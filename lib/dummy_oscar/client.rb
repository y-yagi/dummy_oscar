# frozen_string_literal: true

require "httparty"
require "uri"

class DummyOscar::Client
  def initialize(config_file:, host:, command:, library: nil)
    raise DummyOscar::ArgumentError, "Pleaes specify command argument." if command.nil?

    @command = command
    @commands = {}
    @host = host
    parse_config_file(config_file: config_file, library: library)
  end

  def start
    request = @commands[@command]
    raise DummyOscar::ArgumentError, "'#{@command}' did not find." if request.nil?

    request_options = {}
    request_options[:body] = request["body"] unless request["body"].nil?
    request_options[:query] = request["query"] unless request["query"].nil?

    response = HTTParty.public_send(request["method"].downcase, URI.join(@host, request["path"]).to_s, request_options)
    $stdout.puts response.body
  end

  private

  def parse_config_file(config_file:, library:)
    require(library) if library

    source = ERB.new(File.read(config_file)).result(binding)
    config = YAML.load(source)

    config["requests"].each do |name, request|
      if request["path"].nil? || request["method"].nil?
        raise DummyOscar::ParseConfigError, "You need to specify both `:path` and `:method` in the config file."
      end
      @commands[name] = request
    end
  end
end
