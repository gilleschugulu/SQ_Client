Controller          = require 'controllers/base/controller'
TutorialView        = require 'views/outgame/tutorial-view'
AnalyticsHelper     = require 'helpers/analytics-helper'
LocalStorageHelper  = require 'helpers/local-storage-helper'

module.exports = class TutorialController extends Controller
  title       : 'Tutorial'
  historyURL  : 'tutorial'
  swiper: null
  slides: [
    {
      img: 'images/tutorial/tutoriel_1.jpg'
    }
    {
      img: 'images/tutorial/tutoriel_2.jpg'
    }
    {
      img: 'images/tutorial/tutoriel_3.jpg'
    }
  ]

  index: =>
    AnalyticsHelper.trackEvent 'Tutorial', 'Affichage du Tutorial'
    window.localStorage.setItem('firstTime', false)
    @loadView 'tutorial'
    , =>
      new TutorialView {@currentIndex}
    , (view) =>
      @initializeSwiper()

  initializeSwiper: =>
    @swiper = new SwipeView('#wrapper', {numberOfPages: @slides.length, hastyPageFlip: true, loop: false})
    @view.delegate 'click', '#next-btn', =>
      AnalyticsHelper.trackEvent 'Tutorial', 'Page suivant Tutorial'
      @swiper.next()
    @view.delegate 'click', '.close', =>
      AnalyticsHelper.trackEvent 'Tutorial', 'Quitter le tutorial'
      @redirectTo 'home'

    @view.appendFirstSlides @slides, @swiper
    @swiper.onFlip => @view.appendNewSlides(@slides, @swiper)