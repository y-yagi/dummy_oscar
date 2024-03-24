# frozen_string_literal: true

require "optparse"

class DummyOscar::Cli
  class << self
    def start(argv = ARGV)
      cli = new(argv)
      options = cli.parse

      if options[:mode] == "s"
        DummyOscar::Server.new(config_file: options[:config], port: options[:port], library: options[:library]).start
      else
        DummyOscar::Client.new(config_file: options[:config], command: options[:command], library: options[:library], host: options[:host]).start
      end
    end
  end

  CMD = 'dummy_oscar'
  USAGE = <<~USAGE
  sub commands are:
     s :     run with server mode
     c :     run with client mode
  See '#{CMD} COMMAND --help' for more information on a specific command.
  USAGE

  def initialize(argv)
    @argv = argv
    @options = {}
  end

  def parse
    global_command.order!(@argv)
    @options[:mode] = @argv.shift
    subcommand = subcommands[@options[:mode]]
    unless subcommand
      puts global_command.help
      exit!
    end

    subcommand.order!(@argv)
    raise OptionParser::MissingArgument.new("-C") if @options[:config].nil?
    @options
  end

  private

  def global_command
    @global_command ||= OptionParser.new do |opts|
      opts.banner = "Usage: #{CMD} [options] [subcommand [options]]"
      opts.separator ""
      opts.separator USAGE
    end
  end

  def subcommands
    {
      's' => OptionParser.new do |opts|
        opts.on("-p", "--port NUMBER", "Port number", Integer) do |v|
          @options[:port] = v.to_i
        end

        opts.on("-C", "--config PATH", "Config file path") do |v|
          @options[:config] = v
        end

        opts.on("-r", "--require PATH", "require the library before parse a config file") do |v|
          @options[:library] = v
        end
      end,
      'c' => OptionParser.new do |opts|
        opts.on("-C", "--config PATH", "Config file path") do |v|
          @options[:config] = v
        end

        opts.on("-r", "--require PATH", "require the library before parse a config file") do |v|
          @options[:library] = v
        end

        opts.on("-c", "--command NAME", "Command") do |v|
          @options[:command] = v
        end

        opts.on("-h", "--host NAME", "Host name") do |v|
          @options[:host] = v
        end
      end
    }
  end
end
