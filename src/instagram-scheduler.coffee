class InstagramScheduler
    constructor : (@App)->
        @coordinates = @App.coordinates

        @fetchFromInstagram()
        setTimeout ()=>
            @fetchFromInstagram()
        , 1000 * 60 * 60 * 24
    fetchFromInstagram : ()=>
        #promises  = []
        count = 0
        @App.coordinates = @App.coordinates
        for coordinate in @App.coordinates
            coordinateArray = [coordinate["latitude"], coordinate["longitude"]]
            url = "https://api.instagram.com/v1/media/search?client_id=#{@App.config['instagram']['client_id']}&lat=#{coordinateArray[0]}&lng=#{coordinateArray[1]}&distance=#{@App.config['instagram']['distance']}"
           
            @App.makeRecursiveCall url, "nopage" , "nopage", "data"

        #@App.q.allSettled(promises).then (results)=>
        #    for result in results
        #        for media in result["value"]
        #            @App.findIfNeeded @App.Instagram, media
        #, (err)=>
        #    console.log err
        #console.log "fetchFromInstagram"
module.exports = InstagramScheduler