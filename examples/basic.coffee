Marathon = require '../lib/marathon'
client = new Marathon(base_url: 'http://zk.moddls.com:8080')

client.apps.list()
.then (data) ->
  console.log data.apps
.catch (err) ->
  console.log arguments
