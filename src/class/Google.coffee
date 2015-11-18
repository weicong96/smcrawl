class Google
    primaryKey : "place_id"
    insertedKeys : ["place_id", "name","geometry.location", "types","reference"]
    #specificEntity : {}
    db : {}
    constructor : (@App)->
        @db = @App.Models.GoogleDB
        #@specificEntity = @App.GoogleDetails

    getEntity : (jsonFromRequest)=>     
        if !jsonFromRequest['photo'] and !jsonFromRequest['reviews']
            @getNestedEntitiesJobs(jsonFromRequest)
        return jsonFromRequest

    getNestedEntitiesJobs : (jsonFromRequest)=>
        url = "https://maps.googleapis.com/maps/api/place/details/json?key=#{@App.config['google']['api_key']}&placeid=#{jsonFromRequest[@primaryKey]}" 
        
        @App.makeRecursiveCall(url, "", "","result")
module.exports = Google