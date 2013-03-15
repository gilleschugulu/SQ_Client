Model = require 'models/base/model'

module.exports = class User extends Model
  defaults:
    uuid:         null
    nickname:     'NewPlayer01'
    avatar:       null
    gender:       'male'
    credits:      0
    rank:         8
    notifications:
      ranking: off
      info: off
      decrease_rank: off
    providers:
      facebook: null
      twitter: null

    # stats:
    #   cash:
    #     current:    0
    #     best:       0
    #   games:
    #     played:     0
    #     won:        0
    #   bestLevel:    0
