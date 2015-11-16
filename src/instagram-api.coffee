class Instagram
    constructor : (@App)->
        @App.router.get "/api/media" , @getMedia
    getMedia : (req, res)=>
        if !req.query.page
            page = 0
        else
            page = req.query.page
        pageSize = 100
        @App.Models.InstagramDB.find({}).skip(page * pageSize).limit(pageSize).toArray (err,docs)=> 
            if !err and docs
                for doc in docs
                    doc['time'] = doc['_id'].getTimestamp()
                    doc['relative_time'] = @App.moment(doc['time']).fromNow()

                return @App.sendContent req, res, docs
            else
                return @App.sendErrorCode req, res, 500, err
module.exports = Instagram