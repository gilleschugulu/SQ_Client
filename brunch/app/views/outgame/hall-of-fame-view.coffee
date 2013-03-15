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
    klass = ' '+player.type
    klass += " podium_#{rank}" if rank < 4
    pic = if player.profilepic then player.profilepic+'?width='+picSize+'&height='+picSize else 'http://profile.ak.fbcdn.net/static-ak/rsrc.php/v2/yo/r/UlIqmHJn-SK.gif'
    '<tr class="row-ranking'+klass+'">
      <td class="rank">'+rank+'</td>
      <td class="profilepic"><img src="'+pic+'" /></td>
      <td class="nickname">'+player.nickname+'</td>
      <td class="money">'+player.jackpot+' <span class="star"></span></td>
    </tr>'

  updateRankingList: (players) ->
    el = $('.weekly-ranking', @$el).empty()
    el.append @newPlayerHTML(rank, player, 53) for rank,player of players

  chooseList: (eventTargetEl) ->
    $('.footer-btn', @$el).removeClass('active')
    $(eventTargetEl, @$el).addClass('active')
