template  = require 'views/templates/outgame/hall-of-fame'
i18n      = require 'lib/i18n'
View      = require 'views/base/view'
PreloadHelper = require 'helpers/preload-helper'
User      = require 'models/outgame/user-model'

module.exports = class HallOfFameView extends View
  autoRender: yes
  className: 'hall-of-fame-page fixedSize'
  container: '#page-container'
  template: template
  iphone5Class: 'hall-of-fame-page-568h'

  picSize: 40

  getTemplateData: ->
    @options

  initialize: ->
    s = super
    @interval = setInterval =>
      cd = @calculateDateCount()
      @setCountDown cd.days, cd.hours, cd.minutes
    , 1000
    s

  preloadFacebookAvatars: =>
    $('.photo.not-loaded', @$el).each (index, elem) ->
      elem = $(elem)
      elem.addClass 'loading'
      fbid = elem.data('fbid')
      size = elem.data('size')
      url  = "https://graph.facebook.com/#{fbid}/picture?width=#{size}&height=#{size}"
      # console.log url
      PreloadHelper.preloadAsset url, (result) ->
        elem.removeClass('loading not-loaded')
        elem.css {'background-image':"url(#{url})"} if result.loaded

  newPlayerHTML: (player, position) ->
    gotlife = if player.got_life then 'asked' else ''

    photoClass = if player.fb_id then 'photo not-loaded' else 'photo'

    '<div class="div-ranking">' +
      (if player.position < 4 then '<div class="rank icon"></div>' else "<div class='rank'>#{player.position}</div>") +
      "<span class='#{photoClass}' data-fbid='#{player.fb_id || ''}' data-size='81'></span>" +
      "<span class='username resize'>#{User.getFirstName(player.username)}</span>" +
      "<span class='money'>#{player.jackpot}</span>" +
      (if player.friend then "<div data-id='#{player.fb_id}' class='ask-friend #{gotlife}'></div>" else '') +
    '</div>'

  addRangesSeparatorLogic: (player, lastPlayer, rank) ->
    unless lastPlayer
      new_rank = if player.range is 'stay' then rank else rank + 1
      @addRangeSeparator(player.range, new_rank)
    else
      if player.range isnt lastPlayer.range
        new_rank = if player.range is 'stay' then rank else rank - 1
        @addRangeSeparator(player.range, new_rank)
      else if player.position - lastPlayer.position > 1
        @addSplitRangeSeparator(player.position - lastPlayer.position - 1)

  addRangeSeparator: (direction, rank)->
    msg = i18n.t("view.hall_of_fame.players_#{direction}_rank")
    "<span class='rank_separator #{direction}'>#{msg} #{rank}</span>"

  addSplitRangeSeparator: (range) ->
    text = '... ' + range + ' personne'
    text += 's' if range > 1
    text += ' ...'
    "<div class='range_separator'>#{text}</div>"

  addRankSeparator: (player, position)->
    if position > 0
      previousPlayer = @players[position - 1]
      if previousPlayer.rank + 1 is player.rank or previousPlayer.rank is player.rank
        return ''
    else
      return ''
    '<div class="separator"></div>'

  suggestFriends: (friends) =>
    return '' unless friends.length > 0
    moreFriends = "<div class='redSeparator'>"
    for friend in friends
      moreFriends += "</div>
        <div class='div-ranking moreFriends'>
          <span class='photo not-loaded' data-fbid='#{friend.fb_id}' data-size='81'></span>
          <span class='username resize'>#{User.getFirstName(friend.name)}</span>
          <div data-id='#{friend.fb_id}' class='invite-btn'></div>
      </div>"
    moreFriends

  takeOffFriend: (target) =>
    $(target).parent().css('display', 'none')
    $(".life-value").innerHTML(Parse.User.current().get('health'))

  updateRankingList: (@players, friendsToInvite, options) ->
    el = $('.ranking-container', @$el).empty()

    lastPlayer = null
    for player, index in @players
      if player.range
        el.append @addRangesSeparatorLogic(player, lastPlayer, player.rank)
        el.append @addRankSeparator(player, index)
      el.append @newPlayerHTML(player, index)
      lastPlayer = player

    el.append @suggestFriends(friendsToInvite) if friendsToInvite
    @scrollTo(options.playerPosition)
    @autoSizeText()
    @preloadFacebookAvatars()

    $(".spinner").css('display','none')

  updateRankingListNotConnected: ->
    el = $('.ranking-container', @$el).empty()

    el.append '<a id="no-fb-connected"></a>'
    $(".spinner").css('display','none')

  updateRankingListNoFriends: ->
    el = $('.ranking-container', @$el).empty()

    el.append '<a id="no-friends"></a>'
    $(".spinner").css('display','none')

  chooseList: (eventTargetEl) ->
    $('div' ,'#btn_HoF').removeClass('active')
    $(eventTargetEl).addClass('active')

  calculateDateCount: ->
    today = new Date()
    msPerDay = 24 * 60 * 60 * 1000
    timeLeft = (@options.targetDate.getTime() - today.getTime())
    e_daysLeft = timeLeft / msPerDay
    daysLeft = Math.floor(e_daysLeft)
    yearsLeft = 0
    if daysLeft > 365
      yearsLeft = Math.floor(daysLeft / 365)
      daysLeft = daysLeft % 365
    e_hrsLeft = (e_daysLeft - daysLeft) * 24
    hrsLeft = Math.floor(e_hrsLeft)
    minsLeft = Math.floor((e_hrsLeft - hrsLeft) * 60)
    {
      days   : daysLeft
      hours  : hrsLeft
      minutes: minsLeft
    }

  setCountDown: (days, hours, minutes) ->
    $('#HoF-days', @$el).text (if days < 10 then '0' + days else days)
    $('#HoF-hours', @$el).text (if hours < 10 then '0' + hours else hours)
    $('#HoF-min', @$el).text (if minutes < 10 then '0' + minutes else minutes)

  lifeGiven: (el) ->
    $(el).addClass('asked')

  scrollTo: (i) ->
    el = $('.ranking-container')[0]
    height = $('.div-ranking').height()
    if i > 3 then el.scrollTop = (i - 4)*height

  showLevel: (show = yes) ->
    if show
      $('.content-container .level').removeClass 'hiddened'
    else
      $('.content-container .level').addClass 'hiddened'

  dispose: ->
    clearInterval @interval if @interval?
    super