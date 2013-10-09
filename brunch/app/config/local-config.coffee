# see prod-config.coffee
# DO NOT require() this module directly in the app : see environement-config.coffee

# see config-helper.coffee

Parent = require 'config/preprod-config'

class LocalConfig extends Parent
  # @analytics:
  #   enabled: no

  @pay_game: false

  @services:
    parse:
      app_id : 'ixxjIFjdYTjOeKSZycsaPw8DHndujhvHFX2rNW10'
      js_key : 'XQMt26dlAXV32EmVVEQYwhSK2yYuvD6qDA3HaFqS'
      headers:
        "X-Parse-Application-Id": "ixxjIFjdYTjOeKSZycsaPw8DHndujhvHFX2rNW10"
        "X-Parse-REST-API-Key"  : "gkhPen92iMBY4ZAkjZDtR5lRDmZZ3mM04hjHp3Bg"
    tapjoy:
      currency : '2948f4c1-5a8d-4090-beb1-725c617477c8'
    facebook:
      app_id : '321070437995692'
      like_page_url: 'http://www.facebook.com/'
    adcolony:
      zones:
        SHOP : "vz8cfb94951aa34d79bbf0b2"
    allopass:
      app_id: 297830

module.exports = LocalConfig
