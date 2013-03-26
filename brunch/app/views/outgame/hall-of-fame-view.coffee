template = require 'views/templates/outgame/hall-of-fame'
View = require 'views/base/view'

module.exports = class HallOfFameView extends View
  autoRender: yes
  className: 'hall-of-fame'
  container: '#page-container'
  template: template

  getTemplateData: ->
    @options

  newPlayerHTML: (rank, player, picSize) ->
    if @i is 'pink'
     @i = 'white'
    else
      @i = 'pink'
    color = ' '+@i
    pic = if player.profilepic then player.profilepic else 'http://profile.ak.fbcdn.net/static-ak/rsrc.php/v2/yo/r/UlIqmHJn-SK.gif'
    '<div class="div-ranking'+color+'">
      <span class="rank">'+rank+'</span>
      <div class="profilepic"><img src="'+pic+'" width="'+picSize+'" height="'+picSize+'"/></div>
      <span class="username">'+player.username+'</span>
      <span class="money">'+player.jackpot+'</span>
    </div>'

  updateRankingList: (players) ->
    @i= 'pink'
    el = $('.ranking-container', @$el).empty()
    el.append @newPlayerHTML(rank, player, 40) for rank,player of players

  chooseList: (eventTargetEl) ->
    $('div' ,'#btn_HoF').removeClass('active')
    $(eventTargetEl).addClass('active')
