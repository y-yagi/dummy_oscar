# frozen_string_literal: true

require "optparse"

class DummyOscar::Cli
  class << self
    def start
      options = parse
      server = DummyOscar::Server.new(config_file: options[:config], port: options[:port], library: options[:library])
      server.start
    end

    def parse(argv = ARGV)
      options = {}

      OptionParser.new do |opts|
        opts.on("-p", "--port NUMBER", "Port number", Integer) do |v|
          options[:port] = v.to_i
        end

        opts.on("-C", "--config PATH", "Config file path") do |v|
          options[:config] = v
        end

        opts.on("-r", "--require PATH", "require the library before parse a config file") do |v|
          options[:library] = v
        end
      end.parse!(argv)

      raise OptionParser::MissingArgument.new("-C") if options[:config].nil?

      options
    end
  end
end
