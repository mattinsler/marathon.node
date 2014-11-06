# marathon.node

Marathon v2 API client for Node.js

## Installation
```
npm install marathon.node
```

## Usage

```javascript
var Marathon = require('marathon.node');

var client = new Marathon({base_url: '...'});

client.apps.list().then(function(res) {
  console.log(res.apps);
});
```

## License
Copyright (c) 2014 Matt Insler  
Licensed under the MIT license.
