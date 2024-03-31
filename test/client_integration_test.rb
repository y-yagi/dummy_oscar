# frozen_string_literal: true

require "test_helper"
require "net/http"

class ClientIntegrationTest < Minitest::Test
  include Minitest::Hooks


  def before_all
    @pid = Process.spawn("./exe/dummy_oscar", "s", "-C", "test/fixtures/server_basic.yaml", "-r", "./test/fixtures/library_for_config.rb")
    @host = "http://localhost:8282"
    sleep 2
    super
  end

  def after_all
    Process.kill(:KILL, @pid)
    sleep 1
    super
  end

  def test_client_get
    out = `./exe/dummy_oscar c -C test/fixtures/client_basic.yaml -c hello -h #{@host}`
    assert_equal "hello,world", out.strip
  end

  def test_client_post
    system("./exe/dummy_oscar c -C test/fixtures/client_basic.yaml -c create_user -h #{@host}", exception: true)
  end
end
