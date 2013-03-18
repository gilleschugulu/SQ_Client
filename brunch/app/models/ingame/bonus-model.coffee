Model = require 'models/base/model'

module.exports = class Bonus extends Model
  defaults:
    name: 'noname'
    quantity: 0