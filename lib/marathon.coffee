Rest = require 'rest.node'

Api = {
  Apps: class AppsApi
    constructor: (@client) ->
    list: (cb) -> @client.get('/v2/apps', cb)
    create: (data, cb) -> @client.post('/v2/apps', data, cb)
  
  App: class AppApi
    constructor: (@client, @app_id) ->
      @tasks = new Api.AppTasks(@client, @app_id)
      @versions = new Api.AppVersions(@client, @app_id)
    get: (cb) -> @client.get("/v2/apps/#{@app_id}", cb)
    update: (data, cb) -> @client.put("/v2/apps/#{@app_id}", data, cb)
    destroy: (cb) -> @client.delete("/v2/apps/#{@app_id}", cb)
    
    version: (version_id) -> new ApiAppVersion(@client, @app_id, @version_id)
  
  AppVersions: class AppVersionsApi
    constructor: (@client, @app_id) ->
    list: (cb) -> @client.get("/v2/apps/#{@app_id}/versions", cb)
  
  AppVersion: class AppVersionApi
    constructor: (@client, @app_id, @version_id) ->
    get: (cb) -> @client.get("/v2/apps/#{@app_id}/versions/#{@version_id}", cb)
  
  AppTasks: class AppTasksApi
    constructor: (@client, @app_id) ->
    list: (cb) -> @client.get("/v2/apps/#{@app_id}/tasks", cb)
    killAll: (cb) -> @client.delete("/v2/apps/#{@app_id}/tasks", cb)
    kill: (task_id, cb) -> @client.delete("/v2/apps/#{@app_id}/tasks/#{task_id}", cb)
  
  Tasks: class TasksApi
    constructor: (@client) ->
    list: (cb) -> @client.get('/v2/tasks', cb)
}

class Marathon extends Rest
  @hooks:
    # server_token: (server_token) ->
    #   (request_opts, opts) ->
    #     request_opts.headers ?= {}
    #     request_opts.headers['X-Postmark-Server-Token'] = server_token
    
    json: (request_opts, opts) ->
      request_opts.headers ?= {}
      request_opts.headers.Accept = 'application/json'
      request_opts.headers['Content-Type'] = 'application/json'
    
    json_data: (request_opts, opts) ->
      request_opts.json = opts
    
    querystring_data: (request_opts, opts) ->
      request_opts.qs = opts
  
  constructor: (@options = {}) ->
    throw new Error('Must supply base_url to the Marathon constructor. e.g. new Marathon({base_url: "http://marathon.example.com:8080"})') unless @options.base_url?
    super(base_url: @options.base_url.replace(/v[0-9]\/?$/g, ''))
    
    @hook('pre:request', Marathon.hooks.json)
    # @hook('pre:request', Marathon.hooks.server_token(@options.api_key)) if @options.api_key?
    @hook('pre:get', Marathon.hooks.querystring_data)
    @hook('pre:put', Marathon.hooks.json_data)
    @hook('pre:post', Marathon.hooks.json_data)
    
    @apps = new Api.Apps(@)
    @tasks = new Api.Tasks(@)
  
  app: (app_id) -> new Api.App(@, app_id)
  task: (task_id) -> new Api.Task(@, task_id)
  
  info: (cb) -> @client.get('/info')
  ping: (cb) -> @client.get('/ping')
  metrics: (cb) -> @client.get('/metrics')

module.exports = Marathon
