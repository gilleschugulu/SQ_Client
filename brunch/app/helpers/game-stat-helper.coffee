I18n = require 'lib/i18n'

module.exports = class GameStatHelper

  @_stats = {}

  @setBestScore: (value) ->
    @_setBest('best_score', value)
    @setBestWeekScore value

  @setBestWeekScore: (value) ->
    current_week = (new Date).getWeek()
    console.log 'setBestWeekScore', value, current_week
    if @_getStat('week_score') == current_week
      console.log 'same week, so best set'
      @_setBest('game_week_score', value)
    else
      console.log 'different week, so set score and date', value, current_week
      @_setStat('week_score', current_week)
      @_setStat('game_week_score', value)

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

    # stats.sports[sport].total will never be 0, since += 1. So no / 0
    percent = (stats.sports[sport].good / stats.sports[sport].total) * 100
    stats.sports[sport].percent = parseFloat(percent.toFixed(2))

    user.set('stats', stats)
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
    answers_count = (@_getStat('wrong_answers_count') + @_getStat('good_answers_count')) | 1
    {
      stats:
        best_score: @_getStat('best_score')
        avg_score: parseFloat((@_getStat('sum_score') / (@_getStat('games_played_count') | 1)).toFixed(2))
        percent_answer: @getPercentAnswer() + '%'
        average_time: parseInt(@_getStat('sum_time_question') / answers_count, 10) + ' ms'
        games_played_count: @_getStat('games_played_count')
        best_row: @_getStat('best_row')
        best_sport: @getBestSport()
      score: @_getStat('game_week_score')
      sports: @getAllSports()
    }

  @getBestSport: ->
    return I18n.t('helper.stats.no_best_sport') if _.keys(sports = @getAllSports()).length == 0

    best_sport = _.max sports, (sport) ->
      sport.percent
    best_sport.name

  @getAllSports: ->
    @getStats().sports

  @getPercentAnswer: ->
    parseFloat(((@_getStat('good_answers_count') / (@_getStat('wrong_answers_count') + @_getStat('good_answers_count'))) * 100).toFixed(2)) | 0

  @reset: ->
    @_stats = {
      game_good_answers_count:  0
      game_wrong_answers_count: 0
      game_best_row:            0
    }


  # Will save stats on Parse. 
  # Only use this at the end of a game to avoid sending to many call to Parse.
  @saveStats: ->
    user = Parse.User.current()
    stats = $.extend(user.get('stats'), @_stats)

    real_stats = {}
    for stat_name in ['best_score', 'sum_score', 'games_played_count', 'wrong_answers_count', 'good_answers_count', 'sum_time_question', 'games_played_count', 'best_row', 'sports', 'game_week_score', 'week_score']
      real_stats[stat_name] = stats[stat_name]

    real_stats.good_answers_count += @_stats.game_good_answers_count
    real_stats.wrong_answers_count += @_stats.game_wrong_answers_count
    real_stats.best_row = @_stats.game_best_row if @_stats.game_best_row > real_stats.best_row

    user.set('stats', real_stats).save()


  # Internal methods used to dry logic to update stats
  @_incrementStat: (key, value = 1) ->
    value = parseInt(value)
    @_setStat(key, (@_getStat(key) | 0) + value)

  @_setBest: (key, value) ->
    value = parseInt(value)
    if @_getStat(key)
      @_setStat(key, value) if value > @_getStat(key)
    else
      @_setStat(key, value)

  @_setStat: (key, value) ->
    console.log '_setStat', key, value
    @_stats[key] = value
    console.log @_stats
    @_stats[key]

  @_getStat: (key) ->
    @_stats[key] | 0