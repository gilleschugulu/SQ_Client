# this configuration serves as base for other configurations (local|preprod)
# they inherit all the properties from here and can override them
# DO NOT require() this module directly in the app : see environement-config.coffee

# see config-helper.coffee

class ProdConfig
  @app_name: 'Sport Quiz 2'

  @log:                  false
  @long_version_format:  false

  @analytics:
    enabled: no
    google : ['']

  @services:
    tapjoy:
      currency : '2948f4c1-5a8d-4090-beb1-725c617477c8'
    facebook:
      app_id : '321070437995692'
      like_page_url: 'http://www.facebook.com/'
      createAnyway: false
    adcolony:
      zones:
        SHOP : "vz8cfb94951aa34d79bbf0b2"

  @gamecenter:
    leaderboard : 'total_jackpot'

module.exports = ProdConfig
