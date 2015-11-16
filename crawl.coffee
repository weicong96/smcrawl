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
moment = require "moment"

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
        @moment = moment

        @coordinatesFromKml().then (result)=>
            @coordinates = result
            client.use("jobs").onSuccess (data)=>
                @con = client
                mongodb.connect config.mongodb , (err,db)=>
                    if !err
                        #@clearJobs()
                        @listenToTube()
                        @Models.GoogleDB = db.collection "google"
                        @Models.InstagramDB = db.collection "instagram"

                        @Google = new Google(@)
                        @Instagram = new Instagram(@)

                        googlesch = new GoogleScheduler(@)
                        #instagramsch = new InstagramScheduler(@)
    setRedisValue : (key , value)=>
        redis.set key, value
    getRedisKey : (key)=>
        defer = q.defer()
        redis.get key , (err, value)=>
            defer.resolve value
        return defer.promise;
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
                            if doc["ops"][0]["caption"]
                                console.log doc["ops"][0]["caption"]["text"]
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
        url = arguments[0]
        _type = ""
        if url.indexOf("instagram") > -1 
            _type = "instagram"
        else if url.indexOf("google") > -1
            _type = "google"
        jobPayload = 
            data : arguments
            type : _type

        @con.put(JSON.stringify(jobPayload)).onSuccess (data)=>
    clearJobs : ()=>
        @con.watch('jobs').onSuccess (data)=>
            @con.reserve().onSuccess (job)=>
                console.log job
                console.log "clear job #{job.id}"
                @con.deleteJob(job.id).onSuccess ()=>
                    @clearJobs()
                    @clearJobs()
    listenToTube : ()=>
        @con.watch('jobs').onSuccess (data)=>
            @con.reserve().onSuccess (job)=>
                json_string = job.data
                job_id = job.id
                console.log job_id
                if json_string 
                    json_data = JSON.parse(json_string).data
                    if json_data
                        arr = Object.keys(json_data).map (key)=>
                            return json_data[key]
                        unixts = new @moment().startOf('hour').unix()
                        
                        model = null
                        type = JSON.parse(json_string).type
                        if type is "instagram"
                            model = @Instagram
                        if type is "google"
                            model = @Google
                        @getRedisKey(type+"_"+unixts).then (value)=>
                            if value <= (@config[type]['query_limit']-1)
                                @makeRequest.apply(null, arr).then (res)=>
                                    @getRedisKey(type+"_"+unixts).then (value)=>
                                        value = parseInt value
                                        if !value
                                            value = 0 
                                        value = value + 1
                                        console.log "#{type}_#{unixts} : #{value}"
                                        @setRedisValue type+"_"+unixts, value
                                    console.log res['pages']+" pages "
                                    for media in res['data']
                                        @findIfNeeded model , media

                                    @con.deleteJob(job_id).onSuccess ()=>
                                        console.log "destry job #{job_id}"
                                        @listenToTube() #tube doesn't listen constantly? kind of a recursive call
                            else
                                console.log "query limit reached for #{@moment(unixts * 1000).format()} "
                                
                                @con.release(job_id, 0, @config[type]['query_interval']/1000)
                                @listenToTube()
                    else
                        @listenToTube()
                else
                    @listenToTube()
    #Read from beanstalkd tube
    #Then make request after that
    makeRequest : (_url, token, urlTokenKey, entriesKey, entries, previousResponse, pages)=>
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

            if pages is NaN or pages is undefined 
                pages = 1
            @request url, (error, response, body)=>
                console.log url
                if body
                    body = JSON.parse body
                     
                    if body[token]
                        setTimeout ()=>
                            @makeRequest(_url, token, urlTokenKey, entriesKey, body[entriesKey], body, pages+1).then (responses)=>
                                Array.prototype.push.apply responses['data'], body[entriesKey]
                                defer.resolve {data : responses['data'] , pages : responses['pages']}
                        ,2000
                    else
                        defer.resolve {data : body[entriesKey], pages : pages}
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
