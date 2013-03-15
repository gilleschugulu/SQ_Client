module.exports = class LocalStorageHelper
  @get: (name) ->
    window.localStorage.getItem(name)

  @set: (name, value, days) ->
    window.localStorage.setItem(name, value)

  @delete: (name) ->
    window.localStorage.removeItem(name)

  @exists: (name) ->
    window.localStorage.getItem(name) != null
