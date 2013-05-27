template = require 'views/templates/outgame/tutorial'
View = require 'views/base/view'

module.exports = class TutorialView extends View
  autoRender: yes
  className: 'tutorial'
  container: '#page-container'
  template: template

  prevBtn: no

  appendFirstSlides: (slides, swiper) ->
    $('#wrapper', @$el).css('position', 'static')
    for i in [0..2]
      page = (if i is 0 then slides.length - 1 else i - 1)
      el = "<img src='#{slides[page].img}'>"
      swiper.masterPages[i].innerHTML = el

  appendNewSlides: (slides, swiper) =>
    @switchBtn(swiper.page, (swiper.page + 1) is slides.length)

    $('ul#pagination li.current', @$el).removeClass('current')
    $('ul#pagination li:nth-child(' + (swiper.page + 1) + ')', @$el).addClass('current')

    for i in [0..2]
      upcoming = swiper.masterPages[i].dataset.upcomingPageIndex
      unless upcoming is swiper.masterPages[i].dataset.pageIndex
        el = "<img src='#{slides[upcoming].img}'>"
        swiper.masterPages[i].innerHTML = el

  switchBtn: (indexPage, isLastPage) ->
    if isLastPage
      $('#next-btn', @$el).css('background-image', 'url(images/tutorial/close_corner.png)')
      setTimeout => 
        $('#next-btn', @$el).addClass('close')
      , 200
    else if indexPage == 0
      @disappearPrevButton()
    else
      @appearPrevButton()
      $('#next-btn', @$el).css('background-image', 'url(images/tutorial/next.png)').removeClass('close')

  appearPrevButton: ->
    return if @prevBtn

    prevBtn = $('#prev-btn', @$el)
    prevBtn.removeClass('animated fadeInLeft fadeOutLeft hidden').show().addClass('animated fadeInLeft').one 'webkitAnimationEnd', ->
      prevBtn.removeClass('animated fadeInLeft')
    @prevBtn = yes

  disappearPrevButton: ->
    prevBtn = $('#prev-btn', @$el)
    prevBtn.removeClass('animated fadeInLeft fadeOutLeft hidden').addClass('animated fadeOutLeft').one 'webkitAnimationEnd', ->
      prevBtn.removeClass('animated fadeOutLeft')
      @endPrevButtonAnimation()
    @prevBtn = no

  endPrevButtonAnimation: ->
    if @prevBtn is false
      prevBtn = $('#prev-btn', @$el)
      prevBtn.hide()