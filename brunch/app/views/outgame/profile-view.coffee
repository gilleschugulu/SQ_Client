View = require 'views/base/view'
template = require 'views/templates/outgame/profile'
mediator = require 'mediator'
PreloadHelper = require 'helpers/preload-helper'

module.exports = class ProfileView extends View
  autoRender: true
  className: 'profile-page fixedSize'
  container: '#page-container'
  template: template
  iphone5Class: 'profile-page-568h'

  getTemplateData: ->
    @options

  displayFbAvatar: (fbid) ->
    elem = $('.picture', @$el)
    url  = "https://graph.facebook.com/#{fbid}/picture?width=159&height=150"
    defaultImage = 'images/common/facebook-default.jpg'
    PreloadHelper.preloadAsset url, (result) ->
      elem.removeClass('loading')
      imageUrl = if result.loaded then url else defaultImage
      elem.css {'background-image':"url(#{imageUrl})"}

  facebookLink: (stopped = no) ->
    if stopped
      $('.picture', @$el).removeClass 'loading'
    else
      $('.picture', @$el).addClass 'loading'

