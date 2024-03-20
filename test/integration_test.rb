# frozen_string_literal: true

require "test_helper"
require "net/http"

class IntegrationTest < Minitest::Test
  include Minitest::Hooks


  def before_all
    @pid = Process.spawn("./exe/dummy_oscar", "s", "-C", "test/fixtures/basic.yaml", "-r", "./test/fixtures/library_for_config.rb")
    @host = "localhost"
    @port = "8282"
    sleep 2
    super
  end

  def after_all
    Process.kill(:KILL, @pid)
    sleep 1
    super
  end

  def test_get
    res = Net::HTTP.start(@host, @port) {|http| http.get("/") }
    assert_instance_of Net::HTTPOK, res
    assert_equal "hello,world", res.body
  end

  def test_not_found
    res = Net::HTTP.start(@host, @port) {|http| http.get("/not_found") }
    assert_instance_of Net::HTTPNotFound, res
    assert_equal "Not found", res.body

    headers = {'Content-type' => 'application/json; charset=UTF-8'}
    res = Net::HTTP.start(@host, @port) {|http| http.post("/", "", headers) }
    assert_instance_of Net::HTTPNotFound, res
    assert_equal "Not found", res.body
  end

  def test_post
    headers = {'Content-type' => 'application/json; charset=UTF-8'}
    res = Net::HTTP.start(@host, @port) {|http| http.post("/users", "", headers) }
    assert_instance_of Net::HTTPNoContent, res
  end

  def test_get_data_from_file
    res = Net::HTTP.start(@host, @port) {|http| http.get("/users") }
    assert_instance_of Net::HTTPOK, res
    assert_equal JSON.parse(File.read("test/fixtures/users.json")), JSON.parse(res.body)
  end

  def test_regex_path
    res = Net::HTTP.start(@host, @port) {|http| http.get("/users/1/books") }
    assert_instance_of Net::HTTPOK, res

    assert_equal [{"title"=>"Abc"}, {"title"=>"deF"}], JSON.parse(res.body)
  end

  def test_require_library
    res = Net::HTTP.start(@host, @port) {|http| http.get("/home") }
    assert_instance_of Net::HTTPOK, res
    assert_equal "This is a home page!", res.body
  end
end
