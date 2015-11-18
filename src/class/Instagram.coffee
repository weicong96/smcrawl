class Instagram
    primaryKey : "id"
    insertedKeys : ["id", "tags","location", "comments","likes","images", "caption", "type"]
    db : {}
    nested : [""]
    constructor : (@App)->
        @db = @App.Models.InstagramDB

    getEntity : (jsonFromRequest)=>
        media = jsonFromRequest
        return media
    getNestedEntitiesJobs : ()=>
        console.log "Get nested!"
module.exports = Instagram