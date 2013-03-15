Chaplin = require 'chaplin'
mediator = require 'mediator'
# Application-specific utilities
# ------------------------------

# Delegate to Chaplin’s utils module
utils = Chaplin.utils.beget Chaplin.utils

_(utils).extend

  # Regex Url addParams
  # -----------------
  addParams: (string, params) ->
    params_to_change = string.match(/(?::|\*)(\w+)/g)
    for i in params_to_change
      new_param = i.substring(1)
      if params[new_param] is undefined
        console.log 'Param Missing:', new_param
        #TODO: add Airbrake notify error
      else
        string = string.replace(i, params[new_param])
    return "#{string}"

  # Underscorize then dasherize
  # ---------------------------
  dasherize: (string) ->
    @underscorize(string).replace /_/g, '-'

module.exports = utils


# TODO : Is it the correct file to put this ?
Array::shuffle ?= -> @sort -> 0.5 - Math.random()
