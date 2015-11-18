class GoogleDetails
    primaryKey : "place_id"
    insertedKeys : ["reviews","photos"]
    db : {}
    constructor : (@App)->
        @db = @App.Models.GoogleDB

    getEntity : (jsonFromRequest)=>
        return jsonFromRequest

    getNestedEntitiesJobs : (model)=>
        return null

module.exports = GoogleDetails