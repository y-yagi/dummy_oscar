# frozen_string_literal: true

require "puma"
require "puma/launcher"

class DummyOscar::Server
  DEFAULT_PORT = 8282

  def initialize(config_file:, port: nil)
    @port = port || DEFAULT_PORT
    @app_builder = DummyOscar::App.build(config_file)
  end

  def start
    conf = Puma::Configuration.new do |user_config|
      user_config.threads(1, 4)
      user_config.port(@port)
      user_config.app { |env| @app_builder.app(env) }
    end
    $stdout.puts("Listening on http://localhost:#{@port}")
    Puma::Launcher.new(conf, log_writer: Puma::LogWriter.null).run
  end

  def terminate
  end
end
