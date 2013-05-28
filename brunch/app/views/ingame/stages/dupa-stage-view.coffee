View        = require 'views/base/view'
template    = require 'views/templates/ingame/stages/dupa-stage'
i18n        = require 'lib/i18n'
SoundHelper = require 'helpers/sound-helper'

module.exports = class DupaView extends View
  propContainerInit: no
  template          : template
  autoRender        : yes
  className         : 'dupa-stage fixedSize'
  container         : '#page-container'
  thresholds        : null
  iphone5Class      : 'dupa-page-568h'

  getTemplateData: ->
    @options

  welcome: (callback) ->
    @autoSizeText()
    callback?()

  # Update timer text, and decrease the red filler
  updateTimer: (duration) ->
    duration = parseInt(duration)
    duration = @options.time if duration > @options.time
    duration = 0 if duration <= 0

    $('.chrono-time', @$el).text duration + 's'

    progress = duration / (@options.time) * 100
    progress = 100 if progress > 100
    progress = Math.abs(100 - progress)

    $('.chrono-container .chrono-filler', @$el).css('top', progress + '%')

  updateCountdownTimer: (duration) ->
    countdown = $('#countdown', @$el)
    duration = parseInt(duration)

    if duration > 0
      @dispayNewCountdownValue(duration, countdown)
    else if duration is 0
      @dispayNewCountdownValue('GO !', countdown)

  dispayNewCountdownValue: (duration, countdown) ->
    countdown = $('#countdown', @$el) unless countdown

    countdown.html(duration).removeClass('hidden animated fadeIn')
    setTimeout -> 
      countdown.addClass('animated fadeIn')
    , 0

  hideCountdownValue: ->
    $('#countdown').hide()

  clearTimer: ->
    $('.chrono-container #time', @$el).empty()

  # Remove question text, and 4 propositions. Also remove theme
  removeQuestion: (callback) ->
    $('#text-block', @$el).removeClass('active')
    $('.proposition', @$el).removeClass('success error')
    $('#question', @$el).empty()
    callback?()

  # Display question text, and 4 propositions. Also display theme
  showQuestion: (question, callback) ->
    setTimeout =>
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

  # Getter method
  # Return the proposition described in the given element
  chooseProposition: (targetElement, callback) ->
    propositionEl = $(targetElement, @$el)
    propositionEl.addClass 'selected'
    callback(propositionEl.data('id'))

  # Getter method
  # Return the bonus described in the given element
  chooseBonus: (targetElement, callback) ->
    propositionEl = $(targetElement, @$el)
    callback(propositionEl.attr('id'))

  # Update/animate the clicked button color.
  # If the player has a wrong answer, also update/animate the correct answer
  updateAnswerButton: (propositionId, correctAnswer, status, callback) ->
    klass = if status then 'success' else 'error'
    callbackDelay = 500
    propositionEl = $('.proposition[data-id="'+propositionId+'"]', @$el)
    propositionEl.parent().removeClass('animated pulse').addClass(klass + ' animated fadeIn').one 'webkitAnimationEnd', ->
      $(@).removeClass('animated fadeIn')

    if status is false
      answerEl = $('.proposition[data-id="'+correctAnswer+'"]', @$el)
      answerEl.parent().removeClass('animated pulse').addClass('success animated flipInX').one 'webkitAnimationEnd', ->
        $(@).removeClass('animated flipInX')
      callbackDelay = 750

    setTimeout =>
      callback()
    , callbackDelay

  # Play sound when player answer question. A sound if player is wrong. If he's right, the sound will depend of the threshold index
  playQuestionSound: (currentThresholdIndex, result) ->
    if result
      SoundHelper.play('good_answer_' + currentThresholdIndex)
    else
      SoundHelper.play('wrong_answer')

  # Update the jackpot block
  # Update the displayed score, and move the highlighted block. Also update the jackpot marker (other method)
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

  # Update the jackpot marker. Move both block and arrow
  updateJackpotMarker: (currentThresholdIndex, result = true) ->
    el = $('.jackpot-container', @$el)

    # Position go for 91 to 10. May need some... adaptation
    height = (currentThresholdIndex + 1) * 9 + 1

    klass = if result then 'bounce' else 'inverseBounce'
    $('#jackpot-marker', el).css('top', height + '%').one 'webkitTransitionEnd', ->
      $(@).addClass(klass + ' animated').one 'webkitAnimationEnd', ->
        $(@).removeClass(klass + ' animated')

  # Display the quantity of bonus for the specified bonus
  updateBonus: (targetElement, quantity, callback) ->
    targetElement = $(targetElement, @$el)
    $('.quantity', targetElement).html(quantity)
    callback?()

  # Bonus fifty_fifty. Hide some propositions, with some animation. Also hide concerned massOpinion block
  hideSomeAnswers: (propositions, callback) ->
    for proposition in propositions
      $(".proposition[data-id='#{proposition.id}']").addClass('animated fadeOut').one 'webkitAnimationEnd', ->
        $(@).hide().removeClass('animated fadeOut')
      $(".proposition-container[data-id='#{proposition.id}'] .massOpinion").addClass('animated fadeOut').one 'webkitAnimationEnd', ->
        $(@).hide().removeClass('animated fadeOut')
    callback?()

  # Bonus mass. Display red dots, with given numbers inside
  displayMass: (propositions, callback) ->
    for proposition in propositions
      $(".proposition-container[data-id='#{proposition.id}'] .massOpinion").html(proposition.massOpinion + '%').show().addClass('animated rotateIn').one 'webkitAnimationEnd', ->
        $(@).removeClass('animated rotateIn')
    callback?()

  # Bonus double_score. Arrow and highlighted block now gold
  doubleScoreActivated: ->
    $('.highlighted').addClass('gold')
    $('.highlighted').parent().addClass('gold')
    $('#jackpot-marker').addClass('gold')

  # Bonus double_score. Arrow and highlighted block get back to normal color
  doubleScoreDeactivated: ->
    $('#jackpot-marker').removeClass('gold')