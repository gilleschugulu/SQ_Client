Controller    = require 'controllers/base/controller'
MoreGamesView = require 'views/outgame/more-games-view'
ConfigHelper  = require 'helpers/config-helper'

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
    ApiCallHelper.fetch.moreGames (@content) =>
      @view?.setContent @content
