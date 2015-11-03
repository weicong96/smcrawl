#Not sure if there is the need to use beanstalkd, so shall not use it for now

            #@App.client.connect "127.0.0.1:11300", (err,connection)=>
            #    connection.put 0, 0, 1, JSON.stringify(job_data),(err,job_id)=>
            #        console.log job_id
Q = require "q"
class GoogleScheduler
    constructor : (@App)->
        @coordinates = @App.coordinates

        @fetchFromGoogle()
        setInterval ()=>
            @fetchFromGoogle()
        , 1000 * 60 * 60 * 24

    fetchFromGoogle : ()=>
        promises  = []
        count = 0
        #@coordinates = @coordinates[0..0]
        for coordinate in @coordinates
            coordinateArray = [coordinate["latitude"], coordinate["longitude"]]
            promises.push @getPlaces(coordinateArray)
        Q.allSettled(promises).then (results)=>
            for result in results
                for _place in result["value"]
                    console.log _place["name"]
                    place = 
                        place_id : _place["place_id"]
                        name : _place["name"]
                        location : _place["geometry"]["location"]
                        types : _place["types"]
                        reference : _place["reference"]
                    @App.Models.GoogleDB.find {place_id : place["place_id"]}, (err,doc)=>
                        if !err and doc
                            if !doc #If found this place, don't insert. 
                                @App.Models.GoogleDB.insert place, (err,doc)=>
                                    if !err and doc
                                        console.log place["place_id"]


        console.log "Completed fetch of all coordinates #{@coordinates.length}"
    getPlaces : (coordinates, entries, pagetoken)=>
        if !entries 
            console.log "entries null!"
            entries = []
        q = Q.defer();
        url = ""
        if pagetoken
            url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=#{@App.config['google']['api_key']}&location=#{coordinates[0]},#{coordinates[1]}&radius=#{@App.config['google']['distance']}&pagetoken=#{pagetoken}"
        else 
            url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=#{@App.config['google']['api_key']}&location=#{coordinates[0]},#{coordinates[1]}&radius=#{@App.config['google']['distance']}"
        @App.request url , (error,response,body)=>
            if body
                body = JSON.parse(body)
                if body["next_page_token"]
                    setTimeout ()=>
                        @getPlaces(coordinates, body["results"], body["next_page_token"]).then (responses)=>
                            Array.prototype.push.apply(responses, body["results"])

                            q.resolve(responses)
                    , 2000
                else
                    q.resolve(body["results"]);
        return q.promise;
module.exports = GoogleScheduler