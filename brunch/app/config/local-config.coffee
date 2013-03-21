# see prod-config.coffee
# DO NOT require() this module directly in the app : see environement-config.coffee

# see config-helper.coffee

Parent = require 'config/preprod-config'

class LocalConfig extends Parent
  @analytics:
    enabled: no

  @services:
    tapjoy:
      currency : 'f03160d9-d7b5-4ab3-91c7-b165d92ab81f'
    facebook:
      app_id : '471676116208363'
      like_page_url: 'http://www.facebook.com/'
      createAnyway: true
    adcolony:
      zones:
        SHOP : "vz316622b002ac48da9149a2"

module.exports = LocalConfig
