express = require 'express'
request = require 'request'
morgan  = require 'morgan'

app = express()

###############################################################################
# Configuration                                                               #
###############################################################################
app.set 'port', (process.env.PORT || 3000)

###############################################################################
# Middleware                                                                  #
###############################################################################
app.use morgan('combined')

app.use (req, res, next) ->
  res.header 'Access-Control-Allow-Origin', '*'
  next()

app.use (req, res, next) ->
  if !process.env.LF_KEY?
    res.send {}
  else
    next()

###############################################################################
# Routes                                                                      #
###############################################################################
app.get '/jam', (req, res) ->
  res.send {} if !process.env.JAM_NAME?
  url =  "http://api.thisismyjam.com/1/#{process.env.JAM_NAME}.json"

  request url, (error, response, body) ->
    if !error and response.statusCode == 200
      data = JSON.parse(body)
      data.jam.combinedTruncated = "#{data.jam.title} by #{data.jam.artist}"
      res.send JSON.stringify(data.jam)
    else
      res.send {}

app.get '/nowplaying', (req, res) ->
  res.send {} if !process.env.LF_NAME? and !process.env.LF_KEY?
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

###############################################################################
# Server                                                                      #
###############################################################################
app.listen app.get('port'), ->
  console.log 'Listening on port ' + app.get('port') + '.'
