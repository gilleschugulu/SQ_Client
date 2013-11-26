# this configuration serves as base for other configurations (local|preprod)
# they inherit all the properties from here and can override them
# DO NOT require() this module directly in the app : see environement-config.coffee

# see config-helper.coffee

class ProdConfig
  @app_name: 'Sport Quiz 2'

  @log:                  no
  @long_version_format:  false

  @analytics:
    enabled: yes
    google :
      web    : ['UA-44691623-1']
      mobile : ['UA-44691219-1']

  @pay_game: true

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
      like_page_url: 'https://www.facebook.com/pages/SportQuiz/223149367863583'
    adcolony:
      zones:
        SHOP : "vz8cfb94951aa34d79bbf0b2"
    allopass:
      app_id: 297830

  @gamecenter:
    leaderboard : '2'

module.exports = ProdConfig
