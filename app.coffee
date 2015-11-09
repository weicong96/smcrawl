###
 * onemap-crawl
 * https://github.com//onemap-crawl
 *
 * Copyright (c) 2015 
 * Licensed under the MIT license.
###
config = require("./config")
request = require("request")
express = require("express")
mongodb = require("mongodb")
Google = require("./src/google-api")
Instagram = require("./src/instagram-api")
GoogleScheduler = require("./src/google-scheduler")
geolib = require("geolib")

fs = require("fs")
q = require("q")

#client = require('beanstalk_client').Client
class App
    Models : {}
    constructor : ()->
        @config = config
        @request = request
        #@client = client

        @coordinatesFromKml().then (result)=>
            @coordinates = result
        @router = new express()
        @router.use express.json()
        @router.use express.urlencoded()

        @router.use "/js", express.static "#{__dirname}/www/js"
        @router.use "/css", express.static "#{__dirname}/www/css"
        @router.use "/templates", express.static "#{__dirname}/www/templates"
        @router.use "/bower_components" , express.static "#{__dirname}/www/bower_components"
        #Cross origin fix
        @router.use (req, res, next)=>
            res.setHeader "Access-Control-Allow-Origin", "*"
            res.setHeader "Access-Control-Allow-Methods", "GET, POST, PUT, PATCH, OPTIONS, DELETE"
            res.setHeader "Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept"
            res.setHeader "Access-Control-Allow-Credentials", true
            next()
        @router.all "/*", (req, res, next)=>
            regex = new RegExp('^/api')
            if regex.test req['originalUrl']
                return next()
            else    
                res.sendfile "index.html" , {root : __dirname+"/www"}
        
        @router.listen config.port, ()=>
            console.log "Server starting at #{config.port}"
        mongodb.connect config.mongodb , (err,db)=>
            if !err
                
                @Models.GoogleDB = db.collection "google"
                @Models.InstagramDB = db.collection "instagram"

                google = new Google(@)
                insta = new Instagram(@)
    
    coordinatesFromKml : ()=>
        q = q.defer();
        fs.readFile "mapindex.geojson", 'utf-8', (err,data)=>
            if err
                console.log err
            geojson = JSON.parse data
            allCoordinates = []
            for feature in geojson["features"]
                coordinates =  feature["geometry"]["coordinates"]

                polygonCoordinates = []
                for coordinate in coordinates[0]
                    coordinate.splice 2, 1
                    polygonCoordinates.push {longitude : coordinate[0], latitude : coordinate[1]}
                center = geolib.getCenter polygonCoordinates
                allCoordinates.push center
            q.resolve allCoordinates
        return q.promise
    generateCoordinates : (distance)=>
        bottomleft = [1.149, 103.583]
        topright = [1.490, 104.149]
        #   lat, long 
        #   long ->          (32km)
        #   lat x 1.149, 104.149                x 1.490, 104.149(top right)
        #    |
        #    V
        #   (62km)   
        #       x 1.149, 103.583(bottom left)   x 1.149, 104.149
        coordinates = []
        currentLng = bottomleft[1]
        currentLat = bottomleft[0]
        #Move by lat
        while(currentLat < topright[0])
            newPoints = @distanceFrom currentLat, currentLng, distance, 0
            while(currentLng < topright[1])
                newPointsRow = @distanceFrom currentLat, currentLng, 0, distance
                
                coordinates.push [newPoints[0], newPointsRow[1]]
                if currentLng < topright[1]
                    currentLng = newPointsRow[1]
            if currentLat < topright[0]
                currentLat = newPoints[0]
            
            currentLng = newPoints[1]
             
        return coordinates
    distanceFrom : (lat0,lon0, dyLatOffset, dxLngOffset)=>
        pi = Math.PI

        lat = lat0 + (180/pi)*(dyLatOffset/6378137)
        lon = lon0 + (180/pi)*(dxLngOffset/6378137)/Math.cos(lat0)
        return [lat, lon];
    objectid : (id)=>
        return new mongodb.ObjectID id
    sendContent : (req, res,content)=>
        res.status 200
        return res.json content
    sendError: (req, res, error, content)=>
        res.status error
        return res.end content
new App()
module.exports = App
