I18n = require 'lib/i18n'

# This helper is used to track player data ingame, and display them when needed

module.exports = class GameStatHelper

  @_stats = {}

  @setBestScore: (value) ->
    @_setBest('best_score', value)
    @setBestWeekScore value

  @setBestWeekScore: (value) ->
    current_week = (new Date).getWeek()
    if @_getStat('week_score') == current_week
      @_setBest('game_week_score', value)
    else
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
    sport = sport.replace /\w\S*/g, (txt) => 
      txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase()

    stats.sports = {} unless stats.sports
    unless stats.sports[sport]
      stats.sports[sport] =
        percent: 0
        good: 0
        total: 0
        name: sport

    stats.sports[sport].good += 1 if success
    stats.sports[sport].total += 1

    # stats.sports[sport].total will never be 0, since += 1. So no / 0
    stats.sports[sport].percent = Math.round((stats.sports[sport].good / stats.sports[sport].total) * 10000) / 100

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
    sports = @getAllSports()
    answers_count = (@_getStat('wrong_answers_count') + @_getStat('good_answers_count'))
    {
      stats:
        best_score        : @_getStat('best_score')
        avg_score         : Math.round((@_getStat('sum_score') / (@_getStat('games_played_count') || 1)) * 100) / 100
        percent_answer    : @getPercentAnswer() + '%'
        average_time      : Math.round(@_getStat('sum_time_question') / (answers_count || 1)) + ' ms'
        games_played_count: @_getStat('games_played_count')
        best_row          : @_getStat('best_row')
        best_sport        : @getBestSport(sports)
      score: @_getStat('game_week_score')
      sports: sports
    }

  @getBestSport: (sports) ->
    return I18n.t('helper.stats.no_best_sport') if _.keys(sports).length == 0
    best_sport = _.max sports, (sport) ->
      sport.percent
    if best_sport.percent
      best_sport.name?.substring(0, 12)
    else
      null

  @getAllSports: () ->
    sports = @getStats().sports

    defaultSport = 'Tous Sports'
    real_sports = {}
    for sport in ["Auto Moto", "Cyclisme", "Football Francais", "Football International", "Rugby", "Tennis", defaultSport]
      real_sports[sport] = 
        name   : sport
        percent: 0

    defcnt = 0
    for sportName, sportValue of sports
      if real_sports[sportName]?
        real_sports[sportName].percent = sportValue.percent
      else
        real_sports[defaultSport].percent += sportValue.percent
        defcnt++
    
    real_sports[defaultSport].percent = Math.round(real_sports[defaultSport].percent / defcnt * 100) / 100 if defcnt > 0
    real_sports

  @getPercentAnswer: ->
    Math.round(@_getStat('good_answers_count') / ((@_getStat('wrong_answers_count') + @_getStat('good_answers_count')) || 1) * 10000) / 100

  @reset: ->
    @_stats = Parse.User.current().get('stats')


  # Will save stats on Parse. 
  # Only use this at the end of a game to avoid sending to many call to Parse.
  @saveStats: ->
    user = Parse.User.current()
    stats = $.extend(user.get('stats'), @_stats)

    real_stats = {}
    for stat_name in ['best_score', 'sum_score', 'games_played_count', 'wrong_answers_count', 'good_answers_count', 'sum_time_question', 'games_played_count', 'best_row', 'sports', 'game_week_score', 'week_score']
      real_stats[stat_name] = if typeof stats[stat_name] is 'object' then stats[stat_name] else stats[stat_name] | 0

    real_stats.good_answers_count  += @_stats.game_good_answers_count
    real_stats.wrong_answers_count += @_stats.game_wrong_answers_count
    real_stats.best_row            = @_stats.game_best_row if @_stats.game_best_row > real_stats.best_row

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
    (@_stats[key] = value)

  @_getStat: (key) ->
    @_stats[key] | 0