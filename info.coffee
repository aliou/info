express = require 'express'
request = require 'request'
morgan  = require 'morgan'

app = express()

app.set 'port', (process.env.PORT || 3000)
app.use morgan('combined')

app.use (req, res, next) ->
  res.header 'Access-Control-Allow-Origin', '*'
  next()

app.use (req, res, next) ->
  if !process.env.LF_KEY?
    res.send {}
  else
    next()

app.get '/jam', (req, res) ->
  url =  "http://api.thisismyjam.com/1/#{process.env.JAM_NAME}.json"

  request url, (error, response, body) ->
    if !error and response.statusCode == 200
      data = JSON.parse(body)
      res.send JSON.stringify(data.jam)
    else
      res.send {}

app.get '/nowplaying', (req, res) ->
  url = "http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&user=#{process.env.LF_NAME}&format=json&limit=2&api_key=#{process.env.LF_KEY}"

  request url, (error, response, body) ->
    if !error and response.statusCode == 200
      data = JSON.parse(body).recenttracks.track
      data = data.map (s) -> {
        artist: s.artist['#text'],
        song: s.name,
        album: s.album['#text'],
        nowplaying: s['@attr']?,
      }
      res.send JSON.stringify(data[0])
    else
      res.send {}

app.listen app.get('port'), ->
  console.log 'Listening on port ' + app.get('port') + '.'
