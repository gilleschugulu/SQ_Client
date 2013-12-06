ranks_percentages = require('cloud/ranks_config.js').data
utils = require('cloud/utilities.js')
_ = require('underscore')

# job configured on Parse jobs to run every day (currently they dont allow to run jobs on weekly basis)
# so check first if its monday (just after midnight)

exports.task = (request, response) ->
  date = new Date()
  d = date.getUTCDay()
  # run only on modays after midnight..
  # ATTNETION !  0 = SUNDAY, parse server time is UTC => french time = UTC+2H
  # so the job is scheduled to run on SUNDAYS @22h01 UTC which is MONDAY 00h01 french time !
  # if d isnt 0
  #   if d is 5
  #     return response.error('http://www.youtube.com/watch?v=kfVsfOSbJY0')
  #   return response.error('not a moday yet :(')

  RANK_NOT_COUNTED = -2
  RANK_COUNT_ERROR = -1
  ranks = {}
  for r in [1..10]
    ranks[r + ''] =
      count : RANK_NOT_COUNTED
      up    : 0
      down  : 0

  # count every rank, not reliable with large tables lol
  # calculate number of people to up/down rank
  ranksToCount = Object.keys(ranks).length
  isCountComplete = -> ranksToCount <= 0
  isCountOK = ->
    for rank, v of ranks
      return no if v.count is RANK_NOT_COUNTED or v.count is RANK_COUNT_ERROR
    yes


  for rank of ranks
    do (rank) ->
      query = new Parse.Query('User')
      query.equalTo('rank', rank | 0)
      query.count
        success: (count) ->
          ranks[rank].count = count
          percents          = ranks_percentages[(rank | 0) - 1]
          ranks[rank].up    = Math.ceil(count * percents.up)
          ranks[rank].down  = Math.ceil(count * percents.down)
          ranksToCount--
          return processPlayers() if isCountComplete()
        error: (error) ->
          console.log "FAILED COUNT FOR " + rank
          ranks[rank].count = RANK_COUNT_ERROR
          ranksToCount--
          return processPlayers() if isCountComplete()

  # /!\ WARNING /!\ (2 dezember 2013)
  # the jobs are autokilled after 15 min https://www.parse.com/docs/cloud_code_guide#jobs
  # current processing rate : 110 players in 1.608s
  # => 15min * 60s / ~1.608s * 110p => ~62k players / execution

  processPlayers = ->
    return response.error("could not count all ranks " + JSON.stringify(ranks)) unless isCountOK()
    playersProcessed = 0
    PAGE_SIZE        = 1000 # MAX 1000: parse limitation
    currentRank      = -1
    currentPage      = 0
    countUp          = 0
    # loop through everybody and reset scores, up/down rank required amount of people
    Parse.Cloud.useMasterKey()
    query = new Parse.Query(Parse.User)
    # query.select('score', 'game_row', 'life_given', 'rank')
    query.descending('rank,-score') # https://www.parse.com/questions/multiple-sorts-on-query , https://parse.com/questions/multiplesub-sorts-on-query
    query.limit(PAGE_SIZE)

    processNextPage = ->
      query.skip(PAGE_SIZE * currentPage)
      query.find
        success: (players) ->
          if players.length < 1
            return response.success("#{playersProcessed} players in #{((new Date).getTime() - date.getTime()) / 1000}s")
          for player in players
            playersProcessed++
            if currentRank isnt player.get('rank')
              currentRank = player.get('rank')
              r = ranks[currentRank + '']
              countUp = 0

            r.count--
            countUp++

            # if countUp <= r.up
            #   player.increment('rank')
            # else if r.count < r.down
            #   player.increment('rank', -1)

            player.set('score', Math.floor(Math.random() * 100000)).set('game_row', 1).set('life_given', [])#.save()

          Parse.Object.saveAll players,
            success: ->
              currentPage++
              processNextPage()
            error: -> response.error.apply null, arguments
        error: -> response.error.apply null, arguments

    processNextPage()
