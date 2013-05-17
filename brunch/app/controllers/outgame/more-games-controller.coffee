Controller    = require 'controllers/base/controller'
MoreGamesView = require 'views/outgame/more-games-view'
ConfigHelper  = require 'helpers/config-helper'
SpinnerHelper = require 'helpers/spinner-helper'

module.exports = class MoreGamesController extends Controller
  historyURL: 'more-games'
  title     : 'more-games'
  content   : null

  initialize: ->
    super
    @animate = yes

  index: ->
    @loadContent()
    @loadView 'more-games'
      , ->
        new MoreGamesView()
      , (view) =>
        view.setContent @content if @content
      , {viewTransition: yes}

  loadContent: =>
    SpinnerHelper.start()
    $.ajax
      url     : 'http://moregames.chugulu.com/fr/triviatunes'
      dataType: 'html'
      success : (@content) =>
        @view?.setContent @content
      complete: ->
        SpinnerHelper.stop()
