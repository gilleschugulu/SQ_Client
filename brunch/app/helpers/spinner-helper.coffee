mediator = 'mediator'

module.exports = class SpinnerHelper
  container = '#spinner-container'
  spin_count = 0
  blocking_count = 0

  @startPartial: -> @start yes
  @start: (partial = no) ->
    unless $('#spinner').length > 0
      $(container).addClass if partial then 'active partial' else 'active'
      $(container).append '<div id="spinner" class="spinner"></div>'
    else if not partial # if full screen/blocking spinner is asked it has the priority
      $(container).removeClass 'partial'
    spin_count++
    blocking_count++ unless partial

  @stopPartial: -> @stop yes
  @stop: (partial = no) ->
    if spin_count <= 1
      @remove()
    else
      spin_count--
      if blocking_count <= 1
        $(container).addClass 'partial'
      else
        blocking_count--

  @remove: ->
    $('#spinner').remove()
    $(container).removeClass 'active partial'
    spin_count     = 0
    blocking_count = 0
