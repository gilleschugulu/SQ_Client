View        = require 'views/base/view'
template    = require 'views/templates/ingame/stages/dupa-stage'
i18n        = require 'lib/i18n'

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
    $('.chrono-time', @$el).text (duration - 1) + 's'
    progress = duration / @options.time * 100
    if progress > 100
      progress = 100
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
      $('.proposition', propositionsEl).remove()
      for proposition in question.getPropositions()
        propositionsEl.prepend "<div class='proposition box-align' data-id='#{proposition.id}'>
            <span class='resize'>#{if proposition.masked then '?' else proposition.text}</span>
            <div class='massOpinion'></div>
          </div>"
      @autoSizeText()
      $('.question-theme').text question.get('theme')
      $('.question-content').text question.get('text')
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

  updateAnswerButton: (propositionId, status, callback, question) ->
    @updatePropositionsText question
    if propositionId
      propositionEl = $('.proposition[data-id="'+propositionId+'"]', @$el)
    else
      propositionEl = $('.proposition', @$el)
    klass = if status then 'success' else 'error'
    setTimeout =>
      propositionEl.addClass('animated fadeOut').one 'webkitAnimationEnd', =>
        propositionEl.removeClass('fadeOut').addClass(klass + ' fadeIn').one 'webkitAnimationEnd', ->
          callback()
    , 500

  beforeNextQuestionMessage: (textKey, jackpot, callback) ->
    @displayMessage textKey, jackpot
    setTimeout =>
      $('#question', @$el).addClass('animated fadeOut').one 'webkitAnimationEnd', =>
        $('#question', @$el).removeClass('fadeOut')
        callback?()
    , 2000

  updateJackpot: (jackpot, currentThresholdValue) ->
    el = $('.jackpot-container', @$el)
    $('#total-jackpot', el).text jackpot
    $(".threshold", el).removeClass('highlighted')
    $(".threshold[data-value='#{currentThresholdValue}']", el).addClass('highlighted')
    @updateJackpotMarker(currentThresholdValue)

  updateJackpotMarker: (currentThresholdValue) ->
    el = $('.jackpot-container', @$el)
    currentThresholdIndex = @options.thresholds.indexOf(currentThresholdValue)

    # Position go for 91 to 10. May need some... adaptation
    height = (currentThresholdIndex + 1) * 9 + 1
    $('#jackpot-marker', el).css('top', height + '%')

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
      $(".proposition[data-id='#{proposition.id}'] .massOpinion").html(proposition.massOpinion + '%').show()
    callback?()

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
