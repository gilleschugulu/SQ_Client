i18n = require 'lib/i18n'

module.exports = class RankHelper

  @getRankName: (rankNumber) ->
    return i18n.t "ranks.rank_#{rankNumber}.name"

  @getRankImage: (rankNumber) ->
    return "images/ranks/" + i18n.t("ranks.rank_#{rankNumber}.img_name") + ".png"

  @getRankAttributes: (rankNumber) ->
    {
      name: @getRankName rankNumber
      image: @getRankImage rankNumber
    }
