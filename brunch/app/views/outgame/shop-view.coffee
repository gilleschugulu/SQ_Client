template = require 'views/templates/outgame/shop'
mediator = require 'mediator'
View = require 'views/base/view'

module.exports = class ShopView extends View
  autoRender: yes
  className: 'shop-page fixedSize'
  container: '#page-container'
  template: template
  iphone5Class: 'shop-page-568h'

  getTemplateData: ->
    @options

  getTemplateFunction: ->
    # pack helper here
    super

  updateWallet: (credits, health) ->
    numEl = $('#numbers', @$el)
    $('#credits', numEl).text credits
    $('#hearts',  numEl).text health
    numEl.addClass('pulsing').one 'webkitAnimationEnd', ->
      $(this).removeClass 'pulsing'

  chooseApplePack: (targetElement) ->
    $(targetElement, @$el).data('id')

  chooseFreePack: (targetElement) ->
    $(targetElement, @$el).attr('id')

  chooseLifePackIndex: (targetElement) ->
    $(targetElement, @$el).data('position')

  chooseBonusPackIndex: (targetElement) ->
    $(targetElement, @$el).data('position')

  disableUnavailablePacks: (packIds) ->
    for packId in packIds
      $('.paid-pack[data-id="' + packId + '"]', @$el).addClass 'unavailable'

  removeFreePack: (elemId) ->
    $('.free-pack#'+elemId, @$el).remove()

  toggleTabs: (tabId) ->
    $('.tab', @$el).toggleClass('inactive active')
    $('.content-container', @$el).hide()
    $('.content-container#' + tabId, @$el).show()