exports.task = (request, response) ->
  (new Parse.Query(Parse.User)).equalTo('fb_id', request.params.friendsId.toString()).first
    success: (receiver) ->
      Parse.Cloud.useMasterKey()
      receiver.increment('health', 1).save()
      return response.success {id:receiver.get('fb_id')}
      console.log "GIVED LIFE"
      if request.params.giverId and receiver.get('installationId')
        console.log "GOT A GIVER #{request.params.giverId}"
        (new Parse.Query(Parse.User)).equalTo('objectId', request.params.giverId).first
          success: (giver) ->
            # giver = results[0]
            console.log "GONNA PUSH"
            console.log giver.get('username')
            console.log receiver.get('installationId')
            (new Parse.Query(Parse.Installation)).equalTo('objectId', receiver.get('installationId')).first
              success: (install) ->
                console.log "FOUND INSTALL"
                console.log install.get('deviceToken')
              error: (error) ->
                console.log "COULD NOT FIND INSTALL"
                console.log error
            Parse.Push.send
              where:(new Parse.Query(Parse.Installation)).equalTo('objectId', receiver.get('installationId'))
              data:
                badge: 1
                alert: "#{giver.get('username')} vous a envoyé une vie !"
            ,
              success: ->
                console.log "pushed"
              error: (error) ->
                console.log "push failed"
                console.log error
          error: (obj, error) ->
            console.log "ERROR GIVER"
            console.log obj
            console.log error
    error: (receivers) ->
      response.error receivers
