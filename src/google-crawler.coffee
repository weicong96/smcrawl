Q = require("q")
class Google
    constructor : (@App)->
        @coordinates = @App.coordinates
        @App.router.get "/api/coordinates", (req, res)=>
            return @App.sendContent req ,res, @App.coordinates
        #@App.router.get "/api/places",@getPlace
    getPlace : (req, res)=>
        return @getPlaces([1.3286630568239044,103.90028772480807])
        
    getPlaces : (coordinates, entries, pagetoken)=>
        q = Q.defer();
        url = ""
        if pagetoken
            url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=#{@App.config['google']['api_key']}&location=#{coordinates[0]},#{coordinates[1]}&radius=#{@App.config['google']['distance']}&pagetoken=#{pagetoken}"
        else 
            url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=#{@App.config['google']['api_key']}&location=#{coordinates[0]},#{coordinates[1]}&radius=#{@App.config['google']['distance']}"
        
        @App.request url , (error,response,body)=>
            body = JSON.parse(body)
            if body["next_page_token"]
                setTimeout ()=>
                    @getPlaces(coordinates, body["results"], body["next_page_token"]).then (responses)=>
                        console.log responses
                        return @App.sendContent req, res, responses
                , 2000
            else
                if entries
                    entries.push(body["results"])
                else
                    entries = body["results"]
                q.resolve(entries);
        return q.promise;
module.exports = Google