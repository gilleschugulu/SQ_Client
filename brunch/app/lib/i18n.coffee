_ = require 'underscore'
Chaplin = require 'chaplin'

# Register a insertion method to the String.prototype
String.prototype.fillWith = (strings) ->
  args = strings
  @replace /{(\d+)}/g, (match, number) ->
    if typeof args[number] != 'undefined' then args[number] else match


# Implement the i18n object
i18n =
  localization : {}         # Save the .json localization file
  __locale : null           # language set
  defaultLocale : 'en'      # default language of the application that does not need a localization file
  pathToLocale : 'locale'   # path to localization files

  # Init your localization, call this method in your application when you want to use i18n
  init: () ->
    @setLocale(window.__locale || @defaultLocale)

  setLocale: (newLocale) ->
    locale = newLocale || @defaultLocale

    # load language dynamically if other then current locale
    if locale isnt @__locale
      @__locale       = locale
      @localization   = require(@pathToLocale + "/" + @__locale)

  getLocale : ->
    @__locale

  setDefault: (locale) ->
    @defaultLocale = @__locale = locale


  # Sets an localization object to i18n object
  # setLocalization: (localization) ->
  #   @localization = JSON.parse(localization)


  # Look trough the localization and get the right translation if there is any
  # When there is no translation, it will return the original string with a prepend (?)
  # This helps you to finalize your localization file too
  translate: (id, vars = {}) ->
    template = @localization[@__locale]?[id] or @localization[@__locale[0..1]]?[id]
    unless template?
      try
        self = @
        template = eval("self.localization[self.__locale]." + id)
      catch e
      # You don't need to provide a localization for the default language
      template ?= if @__locale isnt @defaultLocale then "(?) #{id}" else "#{id}"
      # uncomment the following line to show all missing translations in the console
      # console.log("missing [#{@__locale}] #{id}") if console?.log?

    _.template(template, vars)


  # Shortcut for main translation method that also implements placeholder replacements
  #
  # age = 25
  # i18n.t "I'm {0} years old!" age
  #
  # returns (in german)
  #
  # "Ich bin 25 Jahre alt!"

  t: (i18n_key) ->
    # Find the translation
    result = i18n.translate i18n_key

    # clear arguments to array and remove first and last item
    # check wether the arguments come in an array or as plain method arguments
    # depends on how you call this function
    args = Array.prototype.slice.call(arguments, 0)
    if _.isArray(args[1]) then _args = args[1] else _args = args
    if !_.isString _args[_args.length-1] then _args.pop()

    _args.shift() # the original string needs to be shifted anyway

    # Replace placeholders in the localization string with given variables
    result.fillWith _args


# Seal the i18n object
Object.seal? i18n

module.exports = i18n