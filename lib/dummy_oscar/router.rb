# frozen_string_literal: true

class DummyOscar::Router
  Route = Struct.new(:path, :method, :response)

  def initialize
    @routes = []
  end

  def add(path:, method:, response:)
    @routes << Route.new(path, method.downcase, response)
  end

  def find(path:, method:)
    @routes.detect do |route|
      /\A(?:#{route.path})\z/.match?(path) && route.method == method.downcase
    end
  end
end
