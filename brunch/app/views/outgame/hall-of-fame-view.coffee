template  = require 'views/templates/outgame/hall-of-fame'
i18n      = require 'lib/i18n'
View      = require 'views/base/view'

module.exports = class HallOfFameView extends View
  autoRender: yes
  className: 'hall-of-fame-page fixedSize'
  container: '#page-container'
  template: template
  iphone5Class: 'hall-of-fame-page-568h'

  picSize: 40

  getTemplateData: ->
    s = super
    @interval = setInterval =>
      cd = @calculateDateCount()
      @setCountDown cd.days, cd.hours, cd.minutes
    , 1000
    s
    @options


  # TODO : Clean dat' shit
  newPlayerHTML: (player, position) ->
    # TODO : Move this loop out. Only do once.
    alredySend = ''
    for friend in (Parse.User.current().get("life_given") | [])
      if friend is player.id
        alredySend = 'asked'

    friend = if player.friend then "<div data-id='#{player.id}' class='ask-friend "+alredySend+"'></div>" else ''

    # TODO : Use css : nth-child(1), 2 or 3
    # medailles
    rank = '<span class="rank">'+player.rank+'</span>'
    if player.rank is 1
      rank = '<div class="rank first"></div>'
    else if player.rank is 2
      rank = '<div class="rank second"></div>'
    else if player.rank is 3
      rank = '<div class="rank third"></div>'

    pic = if player.profilepic then player.profilepic else 'http://profile.ak.fbcdn.net/static-ak/rsrc.php/v2/yo/r/UlIqmHJn-SK.gif'
    '<div class="div-ranking">'+rank+'<img class="profilepic" src="'+pic+'" width="'+@picSize+'" height="'+@picSize+'"/><span class="username resize">'+player.username+'</span><span class="money">'+player.jackpot+'</span>'+friend+'</div>'

  addPercentagesSeparatorLogic: (uppedNumber, sameNumber, index, rank) ->
    if index == 0
      @addPercentagesSeparator('up', rank + 1)
    else if index == uppedNumber
      @addPercentagesSeparator('stay', rank)
    else if index == sameNumber
      @addPercentagesSeparator('down', rank - 1)

  addPercentagesSeparator: (direction, rank)->
    msg = i18n.t("view.outgame.hall_of_fame.players_#{direction}_rank")
    "<div class='rank_separator #{direction}'>#{msg}</div>"

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
      moreFriends+="</div><div class='div-ranking moreFriends'><img class='profilepic' src='https://graph.facebook.com/#{friend.id}/picture'/><span class='username resize'>#{friend.name}</span><div data-id='#{friend.id}' class='invite-btn'></div></div>"
    moreFriends

  takeOffFriend: (target) =>
    $(target).parent().css('display', 'none')
    $(".life-value").innerHTML(Parse.User.current().get('health'))

  updateRankingList: (@players, friendsToInvite, options) ->
    el = $('.ranking-container', @$el).empty()

    if options.percentages
      uppedNumber = Math.ceil(@players.length * options.percentages.up / 100)
      sameNumber = Math.ceil(@players.length * options.percentages.down / 100) + uppedNumber

    for player, index in @players
      if options.percentages
        el.append @addPercentagesSeparatorLogic(uppedNumber, sameNumber, index, player.rank)
      el.append @addRankSeparator(player, index)
      el.append @newPlayerHTML(player, index)

    el.append @suggestFriends(friendsToInvite) if friendsToInvite
    @scrollTo(options.playerPosition)
    @autoSizeText()

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

  askFriend: (el) ->
    $(el).addClass('asked')

  scrollTo: (i) ->
    el = $('.ranking-container')[0]
    height = $('.div-ranking').height()
    if i>3 then el.scrollTop = (i-4)*height

  dispose: ->
    clearInterval @interval if @interval?
    super