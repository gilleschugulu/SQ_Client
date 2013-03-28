template = require 'views/templates/outgame/hall-of-fame'
View = require 'views/base/view'

module.exports = class HallOfFameView extends View
  autoRender: yes
  className: 'hall-of-fame'
  container: '#page-container'
  template: template

  getTemplateData: ->
    s = super
    @interval = setInterval =>
      cd = @calculateDateCount()
      @setCountDown cd.days, cd.hours, cd.minutes
    , 1000
    s
    @options

  newPlayerHTML: (player, picSize, players) ->
    #separators
    separator = ''
    if @i > 0
      if players[@i-1].rank+1 != player.rank
        separator = '<div class="separator"></div>'
    #friend request button
    friend = if player.friend then '<div class="ask-friend"></div>' else ''
    #pyjama
    if @color is 'pink'
      @color = 'white'
    else
      @color = 'pink'
    #medialles
    rank = '<span class="rank">'+player.rank+'</span>'
    if player.rank == 1
      rank = '<div class="rank first"></div>'
    else if player.rank == 2
      rank = '<div class="rank second"></div>'
    else if player.rank == 3
      rank = '<div class="rank third"></div>'
    @i++
    pic = if player.profilepic then player.profilepic else 'http://profile.ak.fbcdn.net/static-ak/rsrc.php/v2/yo/r/UlIqmHJn-SK.gif'
    separator+
    '<div class="div-ranking '+@color+'">'+rank+'<div class="profilepic"><img src="'+pic+'" width="'+picSize+'" height="'+picSize+'"/></div><span class="username">'+player.username+'</span><span class="money">'+player.jackpot+'</span>'+friend+'</div>'


  updateRankingList: (players) ->
    @i = 0
    @color= 'pink'
    el = $('.ranking-container', @$el).empty()
    el.append @newPlayerHTML(player, 40, players) for player in players

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

