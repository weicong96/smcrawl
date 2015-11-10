class Instagram
    constructor : (@App)->
        @App.router.get "/api/media" , @getMedia
    getMedia : (req, res)=>
        if !req.query.page
            page = 0
        else
            page = req.query.page
        #pageSize = 100 

        @App.Models.InstagramDB.find({}).toArray (err,doc)=> #.skip(page * pageSize).limit(pageSize)
            if !err and doc
                return @App.sendContent req, res, doc
            else
                return @App.sendErrorCode req, res, 500, err
module.exports = Instagram