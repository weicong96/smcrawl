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
        #@coordinates = @coordinates[0..1]
        for coordinate in @coordinates
            coordinateArray = [coordinate["latitude"], coordinate["longitude"]]
            url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=#{@App.config['google']['api_key']}&location=#{coordinateArray[0]},#{coordinateArray[1]}&radius=#{@App.config['google']['distance']}"

            promises.push @App.makeRecursiveCall(url, "next_page_token", "pagetoken","results")
        Q.allSettled(promises).then (results)=>
            for result in results
                for _place in result["value"]
                    @App.findIfNeeded @App.Google, _place

        console.log "Completed fetch of all coordinates #{@coordinates.length}"
    
module.exports = GoogleScheduler