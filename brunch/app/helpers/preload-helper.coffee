spinner = require 'helpers/spinner-helper'
mediator = require 'mediator'

module.exports = class PreloadHelper
  @images        : {}
  @objectImages  : {}

  # preloading of assets for objects like questions and shop items
  # objectType : string : used as key in objectImages to categorize assets
  # objects    : array  : array of objects to preload
  # imageField : string : field in the object that contains image url
  # callback   : function :  called on completion
  @preloadObjectImages: (objectType, objects, imageField, callback) ->
    return unless objects instanceof Array and objects.length > 0 and imageField and objectType
    console.log "PRELOADING " + objectType
    loader = new PxLoader()
    images = (object[imageField] for object in objects when object[imageField])
    @objectImages[objectType] = [] unless @objectImages[objectType]
    imgArray = @objectImages[objectType]
    for image in images.unique()
      if image
        pxImage = loader.addImage image
        imgArray.push pxImage
    loader.addCompletionListener callback if callback
    loader.addCompletionListener =>
      spinner.stop()
    spinner.start()
    loader.start()

  # preloads assets for pages
  # key               : string   : see AssetList.keys (asset_list.js / build_asset_list.rb), represents group of folders to load
  # loaded_callback   : function : (optionnal) called on finish
  # progress_callback : function : (optionnal) called after each image
  @preloadAssets: (key, loaded_callback, progress_callback) ->
    return loaded_callback?() unless key and (AssetsList.keys[key])? and AssetsList.keys[key] instanceof Array and AssetsList.keys[key].length > 0
    loader = new PxLoader()
    @images[key] = []
    imgArray = @images[key]
    tags = AssetsList.keys[key]
    for group in tags
      s = group + '/'
      if AssetsList.assets[s]
        for file in AssetsList.assets[s]
          imgArray.push(loader.addImage(file, tags))
      for assetFolder, a of AssetsList.assets
        if s isnt assetFolder and assetFolder.indexOf(s) isnt -1
          for i in AssetsList.assets[assetFolder]
            imgArray.push(loader.addImage(i, tags))

    if imgArray.length < 1
      loaded_callback() if loaded_callback
      return

    loader.addProgressListener((e) => progress_callback(e.completedCount / e.totalCount)) if progress_callback
    loader.addCompletionListener loaded_callback if loaded_callback
    loader.addCompletionListener =>
      spinner.stop()
    spinner.start()
    loader.start(key)

  # preloads single asset (contest banner etc)
  @preloadAsset: (url, callback) ->
    loader = new PxLoader()
    loader.addImage url
    loader.addCompletionListener callback if callback
    loader.start()

  # internal convenience method
  @removeImages: (imgArray) ->
    return unless imgArray
    file.src = '' for file in imgArray
    imgArray.splice 0, imgArray.length

  # use this to unload object assets
  @removeObjectImages: (objectType) ->
    console.log "UNLOADING " + objectType
    @removeImages @objectImages[objectType]

  # use this to unload page assets
  # with the same key as for preload
  @removeAssets: (key) ->
    if @images and @images[key]
      @removeImages @images[key]
