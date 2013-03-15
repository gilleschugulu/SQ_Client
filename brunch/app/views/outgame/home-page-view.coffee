template = require 'views/templates/outgame/home'
View = require 'views/base/view'

module.exports = class HomePageView extends View
  autoRender: yes
  className: 'home-page'
  container: '#page-container'
  template: template
