# see prod-config.coffee
# DO NOT require() this module directly in the app : see environement-config.coffee

# see config-helper.coffee

Parent = require 'config/prod-config'

class PreprodConfig extends Parent
  @log:                  true
  @long_version_format:  true

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

module.exports = PreprodConfig
