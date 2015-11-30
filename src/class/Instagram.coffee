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
        console.log "get nested"
    getWords : (entity)=>
        words = []
        if entity['caption']
            words = entity['caption']['text'].split(" ")
        
        for tag in entity['tags']
            words.push tag
        return words
module.exports = Instagram