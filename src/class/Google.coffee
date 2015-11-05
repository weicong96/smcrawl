class Google
    primaryKey : "place_id"
    insertedKeys : ["place_id", "name","geometry.location", "types","reference"]
    db : {}
    constructor : (@App)->
        @db = @App.Models.GoogleDB

    getEntity : (jsonFromRequest)=>
        place = 
            place_id : jsonFromRequest['place_id']
            name : jsonFromRequest['name']
            location : jsonFromRequest['location']
            location : jsonFromRequest["geometry"]["location"]
            types : jsonFromRequest["types"]
            reference : jsonFromRequest["reference"]
        return place

module.exports = Google