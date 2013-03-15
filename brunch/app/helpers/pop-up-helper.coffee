mediator    = require 'mediator'
SoundHelper = require 'helpers/sound-helper'

module.exports = class PopUpHelper
  container = '#pop-up-container'

  # TODO: REDO ALL THIS HELPER

  @initialize: (data, callback) ->
    # data structure
    # data =
    #   className: 'the class of the popup'
    #   title: 'title of popup'
    #   message: messages
    #   info: true/false (info popup?, default true)
    #   confirmation: true/false (confirmation popup?, default false)
    #   level: 1-9 (level of the popup, default 1)
    #   key: unique key defined by user

    data = @validate(data)
    template = require "views/templates/#{data.template}"

    $(container).addClass 'active backgroundTransition'
    $(container).append template(data)
    $('.popup', container).addClass('animated bounceInUp').one 'webkitAnimationEnd', ->
      $(this).removeClass 'bounceInUp'

    if data.template is 'pause'
      $("[data-key=#{data.key}]", $(container)).on 'click', '.fx', ->
        $(this).toggleClass 'off'
        SoundHelper.toggleSFX()
      $("[data-key=#{data.key}]", $(container)).on 'click', '.music', ->
        $(this).toggleClass 'off'
        SoundHelper.toggleMusic()

    # bind btn to publish events
    $("[data-key=#{data.key}]", $(container)).on 'click', '.ok', -> mediator.publish 'popup:'+data.key+':ok'
    $("[data-key=#{data.key}]", $(container)).on 'click', '.yes', -> mediator.publish 'popup:'+data.key+':yes'
    $("[data-key=#{data.key}]", $(container)).on 'click', '.no', -> mediator.publish 'popup:'+data.key+':no'

    # automatically dispose popup on click on btn
    $("[data-key=#{data.key}]", $(container)).on 'click', '.remove', => @disposePopup data.key

    # callback
    callback?()

  # Validate the popup data
  # -----------------------
  @validate: (data = {}) ->
    if data
      data.className = 'info' unless data.className
      data.title = 'specify a title' unless data.title
      data.info = true unless data.info
      data.info = false if data.confirmation is true
      data.confirmation = true unless data.confirmation
      data.confirmation = false if data.info is true
      data.level = 1 unless data.level
      data.key = 'foo' unless data.key
      data.template = 'popup' unless data.template

      # data.message must be an array
      if data.message?
        if !$.isArray data.message
          data.message = [data.message]
      else
        data.message = ['specify a message']
    return data

  # Dispose all popups at once
  # --------------------------
  @disposeAll: ->
    $(container).removeClass('backgroundTransition')
    $('.popup', container).addClass('animated bounceOutDown').one 'webkitAnimationEnd', ->
      $(container).off().empty().removeClass('active')
      mediator.publish 'popup:all:disposed'

  # Dispose one popup with his key
  # ------------------------------
  @disposePopup: (key) ->
    $(container).removeClass('backgroundTransition') if $(container).children().length < 2
    $("[data-key=#{key}]", $(container)).addClass('animated bounceOutDown').one 'webkitAnimationEnd', ->
      $(this).off().remove()
      if $(container).children().length < 1
        $(container).empty().removeClass('active')
      mediator.publish 'popup:'+key+':disposed'
