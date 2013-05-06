View        = require 'views/base/view'
template    = require 'views/templates/ingame/stages/dupa-stage'
i18n        = require 'lib/i18n'
SoundHelper = require 'helpers/sound-helper'

module.exports = class DupaView extends View
  propContainerInit: no
  template         : template
  autoRender       : yes
  className        : 'dupa-stage'
  container        : '#page-container'
  thresholds       : null

  getTemplateData: ->
    @options

  welcome: (callback) ->
    @autoSizeText()
    callback?()

  updateTimer: (duration) ->
    duration = parseInt(duration)
    duration = @options.time if duration > @options.time
    duration = 0 if duration <= 0

    $('.chrono-time', @$el).text duration + 's'

    progress = duration / (@options.time) * 100
    progress = 100 if progress > 100
    progressEl = $('.chrono-container .chrono-filler', @$el).css('height', progress + '%')

  clearTimer: ->
    $('.chrono-container #time', @$el).empty()

  removeQuestion: (callback) ->
    $('#text-block', @$el).removeClass('active')#.one 'webkitTransitionEnd', =>
    $('.proposition', @$el).removeClass('success error')
    $('#question', @$el).empty()
    callback?()

  showQuestion: (question, callback) ->
    setTimeout => # http://i.imgur.com/xVyoSl.jpg
      propositionsEl = $('.question-propositions-container', @$el)
      $('.proposition-container', propositionsEl).remove()
      for proposition in question.getPropositions()
        propositionsEl.prepend "<div class='proposition-container box-align' data-id='#{proposition.id}'>
            <span class='proposition resize' data-id='#{proposition.id}'>#{proposition.text}</span>
            <div class='massOpinion'></div>
          </div>"

      $('.proposition-container', @$el).addClass('animated pulse').one 'webkitAnimationEnd', ->
        $(@).removeClass('animated pulse')

      theme = question.get('theme')
      theme = 'Question' unless theme
      $('.question-theme').text(theme)
      $('.question-content').text question.get('text')
      @autoSizeText()
      callback()
    , 0

  chooseProposition: (targetElement, callback) ->
    propositionEl = $(targetElement, @$el)
    propositionEl.addClass 'selected'
    callback(propositionEl.data('id'))

  chooseBonus: (targetElement, callback) ->
    propositionEl = $(targetElement, @$el)
    callback(propositionEl.attr('id'))

  updatePropositionsText: (question) =>
    for proposition in question.getPropositions()
      $(".proposition[data-id='#{proposition.id}']").text proposition.text
    @autoSizeText()

  updateAnswerButton: (propositionId, correctAnswer, status, callback) ->
    klass = if status then 'success' else 'error'
    answerEl = $('.proposition[data-id="'+correctAnswer+'"]', @$el)

    if propositionId
      propositionEl = $('.proposition[data-id="'+propositionId+'"]', @$el)
      propositionEl.parent().addClass(klass)
      if klass isnt 'success'
        answerEl.parent().addClass('success')
    else
      propositionEl = $('.proposition', @$el)

    setTimeout =>
      callback()
    , 500

  beforeNextQuestionMessage: (textKey, jackpot, callback) ->
    @displayMessage textKey, jackpot
    setTimeout =>
      $('#question', @$el).addClass('animated fadeOut').one 'webkitAnimationEnd', =>
        $('#question', @$el).removeClass('fadeOut')
        callback?()
    , 2000

  updateJackpot: (jackpot, currentThresholdValue, options = {}) ->
    el = $('.jackpot-container', @$el)
    currentThresholdIndex = @options.thresholds.indexOf(currentThresholdValue)

    $('#total-jackpot', el).text jackpot
    $(".threshold .highlighted", el).addClass('animated fadeOut').one 'webkitAnimationEnd', ->
      $(@).remove()

    if options?.oldJackpot
      $(".threshold[data-value='#{options.oldJackpot}']", el).removeClass('highlighted gold')

    blockEl = $(".threshold[data-value='#{currentThresholdValue}']", el)

    blockEl.addClass('highlighted')
    blockEl.append("<div class='highlighted'></div>")
    $('.highlighted', blockEl).addClass('animated fadeIn')

    @updateJackpotMarker(currentThresholdIndex, result?.result)

  updateJackpotMarker: (currentThresholdIndex, result = true) ->
    el = $('.jackpot-container', @$el)

    # Position go for 91 to 10. May need some... adaptation
    height = (currentThresholdIndex + 1) * 9 + 1

    klass = if result then 'bounce' else 'inverseBounce'
    $('#jackpot-marker', el).css('top', height + '%').one 'webkitTransitionEnd', ->
      $(@).addClass(klass + ' animated').one 'webkitAnimationEnd', ->
        $(@).removeClass(klass + ' animated')


  updateBonus: (targetElement, quantity, callback) ->
    targetElement = $(targetElement, @$el)
    $('.quantity', targetElement).html(quantity)
    callback?()

  hideSomeAnswers: (propositions, callback) ->
    for proposition in propositions
      $(".proposition[data-id='#{proposition.id}']").css('visibility', 'hidden')
    callback?()

  displayMass: (propositions, callback) ->
    for proposition in propositions
      $(".proposition-container[data-id='#{proposition.id}'] .massOpinion").html(proposition.massOpinion + '%').show()
    callback?()

  doubleScoreActivated: ->
    $('.highlighted').addClass('gold')
    $('.highlighted').parent().addClass('gold')
    $('#jackpot-marker').addClass('gold')

  doubleScoreDeactivated: ->
    $('#jackpot-marker').removeClass('gold')

  finishMessage: (textKey, params, callback) ->
    @displayMessage textKey, params
    setTimeout =>
      $('#question', @$el).addClass('animated fadeOut').one 'webkitAnimationEnd', =>
        $('#question', @$el).removeClass('fadeOut')
        @displayMessage 'finish'
        setTimeout =>
          $('#question', @$el).addClass('animated fadeOut').one 'webkitAnimationEnd', =>
            $('#question', @$el).removeClass('fadeOut')
            callback?()
        , 2000
    , 4000
