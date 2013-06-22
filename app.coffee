express = require 'express'
cfg = require './cfg/config.js'
Firebase = require 'firebase'
Citibike = require 'citibike'
http = require 'http'

app = express()
app.use express.bodyParser()
app.use express.cookieParser()

### Controllers ###
firebase = new Firebase cfg.FIREBASE
citibike = new Citibike

### Routes ###      
app.get '/', (req, res) ->
  
  ### Stream experiment ###
  opts = {
    host: 'appservices.citibikenyc.com',
    port: 80,
    path: '/data2/stations.php?updateOnly=true',
    method: 'GET',
    headers: {
      'Connection': 'keep-alive',
      'Accept': '*/*',
      'User-Agent': 'Example NodeJS Streaming Client'
    }  
  }

  @connection = http.request opts, (response) ->
    data = "";
    response.setEncoding 'utf8'

    response.on 'data', (chunk) ->
      # Received some data
      data += chunk.toString 'utf8'

    response.on 'end', (chunk) ->
      # Connection Closed (Received last byte of data)
      bikes = JSON.parse data
      firebase.set {'Bikes': bikes.results }, (error) ->
        if error
          console.log 'Error: ' + error

        res.send bikes.results


  @connection.end() # If we don't close the connection, node hangs.



### Start the App ###
app.listen "#{cfg.PORT}"
