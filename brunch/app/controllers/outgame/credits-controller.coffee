Controller      = require 'controllers/base/controller'
creditsView    = require 'views/outgame/credits-view'

module.exports = class TutorialController extends Controller
  title       : 'Credits'
  historyURL  : 'credits'
  currentIndex: 1
  maxIndex    : 3

  index: =>
    @loadView 'credits'
    , =>
      new creditsView {@currentIndex}

