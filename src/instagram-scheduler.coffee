class InstagramScheduler
    constructor : (@App)->
        @coordinates = @App.coordinates

    fetchFromInstagram : ()=>
        promises  = []
        count = 0
        #@coordinates = @coordinates[0..10]
        #for coordinate in @coordinates
         #   coordinateArray = [coordinate["latitude"], coordinate["longitude"]]
        #    promises.push @make(coordinateArray)
        
module.exports = InstagramScheduler