# see prod-config.coffee
# DO NOT require() this module directly in the app : see environement-config.coffee

# see config-helper.coffee

Parent = require 'config/preprod-config'

class LocalConfig extends Parent
  @analytics:
    enabled: no

module.exports = LocalConfig
