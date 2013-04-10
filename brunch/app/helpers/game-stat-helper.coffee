module.exports = class GameStatHelper

  @_stats = {}

  @setBestScore: (value) ->
    @_setBest('best_score', value)

  @setBestRow: (value) ->
    @_setBest('game_best_row', value)

  @incrementGamesPlayedCount: ->
    @_incrementStat('games_played_count')

  @incrementSumScore: (value) ->
    @_incrementStat('sum_score', value)
    @

  @incrementSumTimeQuestion: (value) ->
    @_incrementStat('sum_time_question', value)
    @

  @incrementAnswersCount: (success, sport = null) ->
    key = 'game_' + (if success then 'good' else 'wrong') + '_answers_count'
    @_incrementStat(key)
    @_incrementSportAnswersCount(success, sport) if sport

  @_incrementSportAnswersCount: (success, sport) ->
    user = Parse.User.current()
    stats = user.get('stats')

    unless stats.sports[sport]
      stats.sports[sport] =
        percent: 0
        good: 0
        total: 0
        name: sport

    stats.sports[sport].good += 1 if success
    stats.sports[sport].total += 1

    # stats.sports[sport].total will never be 0, since += 1
    percent = (stats.sports[sport].good / stats.sports[sport].total) * 100
    stats.sports[sport].percent = parseFloat(percent.toFixed(2))

    user.set('stats', stats).save()
    @


  @getStats: ->
    @_stats

  @getEndGameScoreStat: ->
    {
      nb_questions: @_getStat('game_wrong_answers_count') + @_getStat('game_good_answers_count')
      good_answers: @_getStat('game_good_answers_count')
      wrong_answers: @_getStat('game_wrong_answers_count')
      best_row: @_getStat('game_best_row')
    }

  @getProfileStat: ->
    @_stats = Parse.User.current().get('stats')
    console.log @_stats
    answers_count = (@_getStat('wrong_answers_count') + @_getStat('good_answers_count')) | 1

    {
      best_score: @_getStat('best_score')
      avg_score: parseFloat((@_getStat('sum_score') / (@_getStat('games_played_count') | 1)).toFixed(2))
      percent_answer: parseFloat(((@_getStat('good_answers_count') / (@_getStat('wrong_answers_count') + @_getStat('good_answers_count'))) * 100).toFixed(2)) + '%'
      average_time: parseInt(@_getStat('sum_time_question') / answers_count, 10) + ' ms'
      games_played_count: @_getStat('games_played_count')
      best_row: @_getStat('best_row')
      best_sport: @getBestSport()
      all_sports: @getAllSports()
    }


  @getBestSport: ->
    best_sport = _.max @getAllSports(), (sport) ->
      sport.percent
    best_sport.name

  @getAllSports: ->
    @getStats().sports


  @reset: ->
    @_stats = {
      game_good_answers_count:  0
      game_wrong_answers_count: 0
      game_best_row:            0
    }

  @saveStats: ->
    user = Parse.User.current()
    stats = $.extend(user.get('stats'), @_stats)

    real_stats = {}
    for stat_name in ['best_score', 'sum_score', 'games_played_count', 'wrong_answers_count', 'good_answers_count', 'sum_time_question', 'games_played_count', 'best_row', 'sports']
      real_stats[stat_name] = stats[stat_name]

    real_stats.good_answers_count += @_stats.game_good_answers_count
    real_stats.wrong_answers_count += @_stats.game_wrong_answers_count
    real_stats.best_row = @_stats.game_best_row if @_stats.game_best_row > real_stats.best_row

    user.set('stats', real_stats).save()

  @_incrementStat: (key, value = 1) ->
    value = parseInt(value)
    @_setStat(key, (@_getStat(key) | 0) + value)

  @_setBest: (key, value) ->
    value = parseInt(value)
    @_setStat(key, value) if value > @_getStat(key)

  @_setStat: (key, value) ->
    @_stats[key] = value
    @_stats[key]

  @_getStat: (key) ->
    @_stats[key] | 0
