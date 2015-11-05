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

geolib = require("geolib")
fs = require("fs")
q = require("q")

client = require('beanstalk_client').Client
class App
    Models : {}
    constructor : ()->
        @config = config
        @request = request
        @client = client

        @coordinatesFromKml().then (result)=>
            @coordinates = result
        mongodb.connect config.mongodb , (err,db)=>
            if !err
                @Models.GoogleDB = db.collection "google"
                @Models.InstagramDB = db.collection "instagram"

                @Google = new Google(@)
                googlesch = new GoogleScheduler(@)
                #instagramsch = new InstagramScheduler(@)
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
                    console.log "already exists"
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
    makeRecursiveCall : (_url, token, urlTokenKey, entriesKey, entries, previousResponse)=>
        if !entries
            entries = []
        defer = q.defer();
        url = ""
        if previousResponse and previousResponse[token]
            url = "#{_url}&#{urlTokenKey}=#{previousResponse[token]}"
        else
            url = "#{_url}"
        @request url, (error, response, body)=>
            if body
                body = JSON.parse body
                if body[token]
                    setTimeout ()=>
                        @makeRecursiveCall(_url, token, urlTokenKey, entriesKey, body[entriesKey], body).then (responses)=>
                            Array.prototype.push.apply responses, body[entriesKey]
                            defer.resolve responses
                    ,2000
                else
                    defer.resolve body[entriesKey]
                    console.log Object.keys(body[entriesKey])
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
