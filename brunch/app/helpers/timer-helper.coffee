mediator = require 'mediator'

module.exports = class TimerHelper
  durationPrecisionCoef: 1
  totalDuration        : 0
  precision            : 0
  interval             : null
  duration             : 0
  onTimeout            : null
  onTick               : null
  startTime            : null
  timerAlreadyStarted  : no
  remaining            : 0
  running              : false

  interruptionDate : null

  constructor: (@onTick) ->
    document.addEventListener 'pause', @onResignActive, false
    document.addEventListener 'resume', @onBecomeActive, false

  # iOS interruptions
  # -----------------
  onResignActive: (e) =>
    # on iOS when the application is interrupted / goes to background, JS is paused, so are timers
    # we need to save the timestamp of the interruption to adjust the timers later
    @interruptionDate = new Date()

  onBecomeActive: (e) =>
    # application becomes active again
    # we need to get current timestamp and apply the difference with pauseDate to the timer
    if @interruptionDate
      resumeDate = new Date()
      offset = (Math.round(@startTime.getTime() - (new Date()).getTime()) / (1000 / @durationPrecisionCoef))
      @adjustDuration offset
      @interruptionDate = null
  # / iOS interruptions

  destroy: =>
    document.removeEventListener 'pause', @onResignActive, false
    document.removeEventListener 'resume', @onBecomeActive, false
    @stop()

  schedule: (duration, @precision, @onTimeout) =>
    @durationPrecisionCoef = Math.pow(10, @precision)
    @duration = duration * @durationPrecisionCoef
    @totalDuration = @duration
    @remaining = @duration
    @stop()
    @onTick?((@duration / @durationPrecisionCoef).toFixed(@precision))
    @

  setDuration: (duration) =>
    @duration = duration

  adjustDuration: (offset) =>
    @remaining += offset
    @setDuration(@duration + offset)
    @onTick?((@duration / @durationPrecisionCoef).toFixed(@precision))

  stop: =>
    return unless @running
    @running = no

    @remaining = @duration
    return unless @interval
    clearInterval @interval
    @interval = null

  tick: =>
    offset = (Math.round(@startTime.getTime() - (new Date()).getTime()) / (1000 / @durationPrecisionCoef))
    @setDuration (@remaining + offset)
    
    @onTick?((@duration / @durationPrecisionCoef).toFixed(@precision))
    if Math.round(@duration) < 0
      @stop()
      @onTimeout?()

  pause: ->
    return unless @running
    @running = no
    @stop()

  start: ->
    return if @running
    @running = yes
    @startTime = new Date()
    @interval = setInterval @tick, Math.pow(10, 3 - @precision)

  resume: -> @start()
    # return if @running
    # @running = yes

    # @schedule @duration, @precision, @onTimeout
    # @start()
