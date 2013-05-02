template = require 'views/templates/outgame/shop'
mediator = require 'mediator'
View = require 'views/base/view'

module.exports = class ShopView extends View
  autoRender: yes
  className: 'shop-page'
  container: '#page-container'
  template: template

  getTemplateData: ->
    @options

  getTemplateFunction: ->
    # pack helper here
    super

  updateWallet: (credits, health) ->
    $('#numbers #credits', @$el).text credits
    $('#numbers #hearts',  @$el).text health

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