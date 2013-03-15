template = require 'views/templates/outgame/shop'
mediator = require 'mediator'
View = require 'views/base/view'

module.exports = class ShopView extends View
  autoRender: yes
  className: 'shop'
  container: '#page-container'
  template: template

  getTemplateData: ->
    @options

  getTemplateFunction: ->
    # pack helper here
    super

  updateWallet: (credits) ->
    $('.cash-value', @$el).text credits

  chooseApplePack: (targetElement) ->
    $(targetElement, @$el).data('id')

  chooseFreePack: (targetElement) ->
    $(targetElement, @$el).attr('id')

  disableUnavailablePacks: (packIds) ->
    for packId in packIds
      $('.paid-pack[data-id="' + packId + '"]', @$el).addClass 'unavailable'

  removeFreePack: (elemId) ->
    $('.free-pack#'+elemId, @$el).remove()
