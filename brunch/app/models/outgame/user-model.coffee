Model = require 'models/base/model'

module.exports = class User extends Parse.User
  defaults:
    uuid:           null
    username:       'NewPlayer01'
    avatar:         null
    credits:        0
    rank:           6
    health:         25
    notifications:  true
    providers:
      facebook: null
      equipe:   null

  stuff: ->
    console.log('coucou')