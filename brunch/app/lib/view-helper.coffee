mediator = require 'mediator'
utils = require 'chaplin/lib/utils'
i18n = require 'lib/i18n'
RankHelper = require 'helpers/rank-helper'

# Application-specific view helpers
# ---------------------------------

# http://handlebarsjs.com/#helpers

# Conditional evaluation
# ----------------------

# Choose block by user login status
Handlebars.registerHelper 'if_logged_in', (options) ->
  if mediator.user
    options.fn(this)
  else
    options.inverse(this)

# Map helpers
# -----------

# Make 'with' behave a little more mustachey
Handlebars.registerHelper 'with', (context, options) ->
  if not context or Handlebars.Utils.isEmpty context
    options.inverse(this)
  else
    options.fn(context)

# Inverse for 'with'
Handlebars.registerHelper 'without', (context, options) ->
  inverse = options.inverse
  options.inverse = options.fn
  options.fn = inverse
  Handlebars.helpers.with.call(this, context, options)

# Evaluate block with context being current user
Handlebars.registerHelper 'with_user', (options) ->
  context = mediator.user?.serialize() or {}
  Handlebars.helpers.with.call(this, context, options)

# Get Chaplin-declared named routes. {{#url "like" "105"}}{{/url}}
Handlebars.registerHelper 'url', (routeName, params...) ->
  url = null
  mediator.publish '!router:reverse', routeName, params, (result) ->
    url = result
  "/#{url}"

# Get translation for key
Handlebars.registerHelper 't', (i18n_key) ->
  args = Array.prototype.slice.call(arguments, 0)
  result = i18n.t i18n_key, args
  # some further escaping
  result = Handlebars.Utils.escapeExpression result
  new Handlebars.SafeString result

# Get number well formated
Handlebars.registerHelper 'niceNumber', (value) ->
  result = value.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ' ')
  result = Handlebars.Utils.escapeExpression result
  new Handlebars.SafeString result

# Each with index
Handlebars.registerHelper "each_with_index", (context, options) ->
  fn = options.fn
  inverse = options.inverse
  ret = ""
  if context and context.length > 0
    i = 0
    j = context.length

    while i < j
      ret = ret + fn(_.extend({}, context[i],
        i: i
        iPlus1: i + 1
        iReverse : j - i - 1
        iReversePlus1 : j - i
      ))
      i++
  else
    ret = inverse(this)
  ret

Handlebars.registerHelper "getRankImage", (rankNumber) ->
  result = RankHelper.getRankImage rankNumber
  result = Handlebars.Utils.escapeExpression result
  new Handlebars.SafeString result

Handlebars.registerHelper "getRankName", (rankNumber) ->
  result = RankHelper.getRankName rankNumber
  result = Handlebars.Utils.escapeExpression result
  new Handlebars.SafeString result