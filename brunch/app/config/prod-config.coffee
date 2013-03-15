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
      currency : 'f03160d9-d7b5-4ab3-91c7-b165d92ab81f'
    facebook:
      app_id : '471676116208363'
      like_page_url: 'http://www.facebook.com/'
    adcolony:
      zones:
        SHOP : "vz316622b002ac48da9149a2"

  @gamecenter:
    leaderboard : 'total_jackpot'

module.exports = ProdConfig
