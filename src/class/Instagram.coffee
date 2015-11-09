class Instagram
    primaryKey : "id"
    insertedKeys : ["id", "tags","location", "comments","likes","images", "caption", "type"]
    db : {}
    constructor : (@App)->
        @db = @App.Models.InstagramDB

    getEntity : (jsonFromRequest)=>
        media = jsonFromRequest
        return media
module.exports = Instagram