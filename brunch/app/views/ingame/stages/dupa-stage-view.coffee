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
    countdown = $('#countdown #countdown-value', (@$el).parent())
    countdown = @initCountdownTimer() if countdown.length is 0

    duration = parseInt(duration)

    if duration > 0
      @dispayNewCountdownValue(duration, countdown)
    else if duration is 0
      @dispayNewCountdownValue('GO !', countdown)

  initCountdownTimer: ->
    div = '<div id="countdown">'
    div += '<div id="countdown-container">'
    div += '<div id="countdown-value"></div>'
    div += '</div>'
    div += '</div>'
    (@$el).parent().prepend(div)
    $('#countdown #countdown-value', (@$el).parent())

  dispayNewCountdownValue: (duration, countdown) ->
    countdown = $('#countdown #countdown-value', @$el) unless countdown
    countdown_container = countdown.parent()

    countdown_container.removeClass('hidden')
    countdown.text(duration).removeClass('hidden big')
    setTimeout -> 
      countdown.addClass('big')
    , 0

  hideCountdownValue: ->
    $('#countdown').hide()

  clearTimer: ->
    $('.chrono-container #time', @$el).empty()

  # Display question text, and 4 propositions. Also display theme
  showQuestion: (question, callback) ->
    setTimeout =>
      propositionsEl = $('.question-propositions-container', @$el)
      $('.proposition-container', propositionsEl).remove()
      for proposition in question.getPropositions()
        propositionsEl.prepend "<div class='proposition-container box-align' data-id='#{proposition.id}'>
              <div class='proposition' data-id='#{proposition.id}'>
                <div class='left part'></div>
                <div class='mid part resize'>#{proposition.text}</div>
                <div class='right part'></div>
              </div>
            <div class='massOpinion'></div>
          </div>"
      $('.proposition-container', @$el).addClass('animated pulse').one 'webkitAnimationEnd', ->
        $(@).removeClass('animated pulse')

      theme = question.get('category') ? 'Question'
      if theme isnt $('.question-theme-ghost', @$el).text()
        ghost = $('.question-theme-ghost', @$el).text(theme)
        $('.question-theme', @$el).addClass('hidden-text').one 'webkitTransitionEnd', ->
          $(@).width(ghost.width()).one 'webkitTransitionEnd', ->
            $(@).text(theme).removeClass('hidden-text')

      photoEl = $('.question-photo', @$el)
      if photoEl.data('sport') isnt question.get('sportCode')
        photoEl.data 'sport', question.get('sportCode')
        photoEl.addClass('hidden-photo').one 'webkitTransitionEnd', ->
          photoEl.css({'background-image' : "url(../images/ingame/sports/#{question.get('sportCode')}.jpg)"}).removeClass('hidden-photo')

      $('.question-content', @$el).text question.get('text')

      @autoSizeText()
      callback?()
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

    if (jackpotMarker = $('#jackpot-marker', el)).hasClass('hidden')
      jackpotMarker.removeClass('hidden').addClass('animated bounceIn').one 'webkitAnimationEnd', ->
        jackpotMarker.removeClass('animated bounceIn')

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
    callback?() unless propositions and propositions.length > 0
    i = propositions.length
    for proposition in propositions
      $(".proposition-container[data-id='#{proposition.id}']").addClass('animated fadeOut').one 'webkitAnimationEnd', ->
        callback?() if --i < 1
        #$(@).removeClass('animated fadeOut')#.addClass('hidden')
      # $(".proposition-container[data-id='#{proposition.id}'] .massOpinion").addClass('animated fadeOut').one 'webkitAnimationEnd', ->
      #   $(@).addClass('hidden').removeClass('animated fadeOut')
    # callback?()

  # Bonus mass. Display red dots, with given numbers inside
  displayMass: (propositions, callback) ->
    for proposition in propositions
      $(".proposition-container[data-id='#{proposition.id}'] .massOpinion").text(proposition.massOpinion + '%').show().addClass('animated rotateIn').one 'webkitAnimationEnd', ->
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