ConfigHelper = require 'helpers/config-helper'

module.exports = class AllopassHelper

  # @generateData: (packId, uuid, packName, packPrice) ->
  #   [packId, uuid, encodeURIComponent(packName), encodeURIComponent(packPrice), 'allopass'].join('_')

  @decodeData: (data) ->
    return {
      packId: data[0]
      packName: decodeURIComponent(data[2])
      packPrice: decodeURIComponent(data[3])
    }

  @sendTransactionToServer: (transactionId, allopassParams) ->
    if transactionId
      serializedData = allopassParams['data'].split('_')
      pack_data = @decodeData(serializedData)
      transaction_data =
        uuid: serializedData[1]
        pack_id: pack_data.packId
        transaction_id: transactionId
        code: allopassParams['RECALL'] ? allopassParams['code']

      GameSendHelper.buyAllopassPack(transaction_data, () =>
        @_handleSuccess()
      ,  =>
        AnalyticsHelper.item('Pack de crédits Allopass', 'Erreur', pack_data.packName, pack_data.packPrice)
        @_handleError()
      )
    else
      @_handleError()

  @productUrl: (pack) ->
    'https://payment.allopass.com/buy/buy.apu?ids=' + ConfigHelper.config.services.allopass.app_id + '&idd=' + pack.product_id

  @onTransactionDone: () ->
    console.log ''

  @_handleSuccess: ->
    @_handleAll()
    PopUpManager.info("L'achat de votre pack a été confirmé. ", 0, ->
      window.close()
      window.open('', '_self', '')
      window.close()
    )

  @_handleError: ->
    @_handleAll()
    PopUpManager.error("Il y a eu un problème lors de l'achat de votre pack. ", 0, ->
      window.close()
      window.open('', '_self', '')
      window.close()
    )

  @_handleAll: ->
    window.resizeTo(480, 320)
    $('#global-container').css('background', 'no-repeat url(../images/pause/background.jpg)')