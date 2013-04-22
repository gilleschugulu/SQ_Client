Controller      = require 'controllers/base/controller'
TutorialView    = require 'views/outgame/tutorial-view'

module.exports = class TutorialController extends Controller
  title       : 'Tutorial'
  historyURL  : 'tutorial'
  currentIndex: 1
  maxIndex    : 3

  index: =>
    @loadView 'tutorial'
    , =>
      new TutorialView {@currentIndex}
    , (view) =>
      view.delegate 'click', '#next-btn', @onClickNext

  onClickNext: =>
    @currentIndex++
    if @currentIndex > @maxIndex
      @redirectTo 'options'
    else
      @view.changeScreen @currentIndex
