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

GoogleScheduler = require("./src/google-scheduler")
InstagramScheduler = require("./src/instagram-scheduler")

Google = require("./src/class/Google")
Instagram = require("./src/class/Instagram")

geolib = require("geolib")
fs = require("fs")
q = require("q")
redis = require("redis").createClient();

nodestalker = require('nodestalker')
client = nodestalker.Client "127.0.0.1:11300"

class App
    Models : {}
    constructor : ()->
        @config = config
        @request = request
        @q = q
        @coordinatesFromKml().then (result)=>
            @coordinates = result

            client.use("jobs").onSuccess (data)=>
                @con = client
                mongodb.connect config.mongodb , (err,db)=>
                    if !err
                        @listenToTube()
                        @Models.GoogleDB = db.collection "google"
                        @Models.InstagramDB = db.collection "instagram"

                        @Google = new Google(@)
                        @Instagram = new Instagram(@)
                        #googlesch = new GoogleScheduler(@)
                        
                        instagramsch = new InstagramScheduler(@)
                        
    setRedisValue : (key , value)=>
        redis.set key, value
    getRedisKey : (key)=>
        redis.get key , (err, value)=>
            return value
    findIfNeeded : (entity, model)=>
        #entity is abstract entity concept
        #model is db collection
        query = {}
        query[entity.primaryKey] = model[entity.primaryKey]
        entity.db.findOne query, (err,doc)=>
            parsedEntity = entity.getEntity(model)

            if !err
                if !doc or doc.length is 0 #If found this place, don't insert. 
                    entity.db.insert parsedEntity, (err,doc)=>
                        if !err and doc
                            console.log "Insert"
                        else
                            console.log err
            else
                console.log "error!"
    coordinatesFromKml : ()=>
        defer = q.defer();
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
            defer.resolve allCoordinates
        return defer.promise
    makeRecursiveCall : ()=>
        @con.put(JSON.stringify(arguments)).onSuccess (data)=>
            console.log "data"
    listenToTube : ()=>
        @con.watch('jobs').onSuccess (data)=>
            @con.reserve().onSuccess (job)=>
                json_string = job.data
                job_id = job.id
                if json_string 
                    json_data = JSON.parse(json_string)
                    arr = Object.keys(json_data).map (key)=>
                        return json_data[key]
                    @makeRequest.apply(null, arr).then (res)=>
                        for media in res
                            @findIfNeeded @Instagram , media
                        @con.deleteJob(job_id).onSuccess ()=>
                            console.log "destry job #{job_id}"
                            @listenToTube() #tube doesn't listen constantly? kind of a recursive call
                else
                    @listenToTube()
    #Read from beanstalkd tube
    #Then make request after that
    makeRequest : (_url, token, urlTokenKey, entriesKey, entries, previousResponse)=>
        if !entries
            entries = []
        defer = q.defer();
        mode = ""
        url = ""
        if previousResponse and previousResponse[token]
            url = "#{_url}&#{urlTokenKey}=#{previousResponse[token]}"
        else
            url = "#{_url}"

        if url.indexOf "instagram" != -1
            mode = "instagram"
        
        #if !previousResponse and mode is "instagram" and @App.getRedisKey("hour") >= 5000
        #reset page count for this hour


        #If its error, probably need to update info here?
        #Reject first if count is reached and schdule antoher one at a later timing
        makeRequest = ()=>
            defer = q.defer();
            @request url, (error, response, body)=>
                if body
                    body = JSON.parse body
                    if body[token]
                        setTimeout ()=>
                            #Maybe will need to cache contents and 
                            @makeRecursiveCall(_url, token, urlTokenKey, entriesKey, body[entriesKey], body).then (responses)=>
                                Array.prototype.push.apply responses, body[entriesKey]
                                defer.resolve responses
                        ,2000
                    else
                        defer.resolve body[entriesKey]
            return defer.promise
        makeRequest().then (res)=>
            defer.resolve res
        return defer.promise
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
