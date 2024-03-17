# frozen_string_literal: true

class DummyOscar::Router
  Route = Struct.new(:path, :method, :response, keyword_init: nil)

  def initialize
    @routes = []
  end

  def add(path:, method:, response:)
    @routes << Route.new(path: path, method: method.downcase, response: response)
  end

  def find(path:, method:)
    @routes.detect do |route|
      route.path == path && route.method == method.downcase
    end
  end
end
