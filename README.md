# DummyOscar

DummyOscar is tool for creating a dummy HTTP server and client.

## Server

You can define a path that returns a dummy response by YAML file. You can use ERB inside the file.

Example:

```yml
# sample.yaml
paths:
  /:
    get:
      response:
        status_code: 200
        body: "hello,world"
  /users:
    post:
      response:
        status_code: 204
    get:
      response:
        status_code: 200
        body: '<%= File.read('test/fixtures/users.json') %>'
  /users/dummy.json:
    get:
      response:
        status_code: 200
        body: <%= {name: 'dummy'}.to_json %>
        content_type: 'application/json'
  /users/.+/books:
    get:
      response:
        status_code: 200
        body: '[{"title":"Abc"},{"title":"deF"}]'
        content_type: 'application/json'
```

You can now start the dummy server.

```bash
$ dummy_oscar s -C sample.yaml
```

```bash
$ curl http://localhost:8282
hello,world
$ curl http://localhost:8282/users/1/books
[{"title":"Abc"},{"title":"deF"}]
```

If you want to use custom methods inside the YAML, you can pass a Ruby file that will load during the parsing of the YAML file.

```bash
$ dummy_oscar s -C sample.yaml -r ./library_for_config.rb
```

## Client

You can define a path and request body by YAML file. You can use ERB inside the file.

Example:

```yml
requests:
  hello:
    path: "/"
    method: "get"
  create_user:
    path: "/users"
    method: "post"
    body: <%= {name: 'dummy'}.to_json %>
```

You can send request like the following.

```bash
$ dummy_oscar c -C sample.yml -h http://localhost:5252 -c hello
```