View          = require 'views/base/view'
PreloadHelper = require 'helpers/preload-helper'

module.exports = class JournalView extends View
  className: 'journal-container completely-hiddened'
  container: '.home-page'

  getTemplateData: ->
    @options.date = @getDate()
    @options

  render: ->
    r = super
    @preloadFacebookAvatars()
    r

  getDate: ->
    date = new Date()
    d = if date.getDate() < 10 then '0' + date.getDate() else date.getDate()
    d += '/'
    d += if date.getMonth() < 9 then '0' + (date.getMonth() + 1) else (date.getMonth() + 1)
    d += '/' + (date.getYear() % 100)
    d

  toggle: ->
    @$el.toggleClass('hiddened').toggleClass('shown')

  appear: ->
    @$el.toggleClass('completely-hiddened').toggleClass('shown')

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