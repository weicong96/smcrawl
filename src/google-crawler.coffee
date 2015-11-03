Q = require("q")
class Google
    constructor : (@App)->
        @coordinates = @App.coordinates
        @App.router.get "/api/coordinates", @getCoordinates
        
    getCoordinates : (req, res)=>
        return @App.sendContent req ,res, @App.coordinates
    
module.exports = Google