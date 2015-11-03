Q = require("q")
class Google
    constructor : (@App)->
        @coordinates = @App.coordinates
        @App.router.get "/api/coordinates", @getCoordinates
        @App.router.get "/api/places", @getPlaces    
    getCoordinates : (req, res)=>
        return @App.sendContent req ,res, @App.coordinates
    getPlaces : (req, res)=>
        @App.Models.GoogleDB.find({}).toArray (err,doc)=>
            if !err and doc
                return @App.sendContent req, res, doc
            else
                return @App.sendErrorCode req, res, 500, err
module.exports = Google