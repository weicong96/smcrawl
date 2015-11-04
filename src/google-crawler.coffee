Q = require("q")
class Google
    constructor : (@App)->
        @coordinates = @App.coordinates
        @App.router.get "/api/coordinates", @getCoordinates
        @App.router.get "/api/places", @getPlaces    
    getCoordinates : (req, res)=>
        return @App.sendContent req ,res, @App.coordinates
    getPlaces : (req, res)=>

        if !req.query.page
            page = 0
        else
            page = req.query.page
        pageSize = 100 

        @App.Models.GoogleDB.find({}).skip(page * pageSize).limit(pageSize).toArray (err,doc)=>
            if !err and doc
                return @App.sendContent req, res, doc
            else
                return @App.sendErrorCode req, res, 500, err
module.exports = Google