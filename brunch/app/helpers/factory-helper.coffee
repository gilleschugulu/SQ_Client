utils = require 'lib/utils'

module.exports = class Factory
  @questionModel: (data) ->
    type = utils.dasherize data.type
    try
      model = require "models/ingame/questions/#{type}-question-model"
    catch e
      console.error "Question type not known : #{type} (#{data.type}). Error :", e
      return null
    new (model)(data)

  @stageConfig: (type) ->
    try
      return require "config/stages/#{type}-stage-config"
    catch e
      console.error "Stage Config type not known : #{type}. Error :", e
    null

  @stageModel: (type, players, data) ->
    config = @stageConfig type
    try
      model = require "models/ingame/stages/#{type}-stage-model"
    catch e
      console.error "Stage Model type not known : #{type}. Error :", e
      return null
    (new model()).setConfig(config).setPlayers(players).setQuestions(data.questions)

  @stageController: (stage, players, data) ->
    model = @stageModel stage.type, players, data
    try
      controller = require "controllers/ingame/stages/#{stage.type}-stage-controller"
    catch e
      console.error "Stage Controller type not known : #{stage.type}. Error :", e
      return null
    (new controller(stage)).setStageModel(model)