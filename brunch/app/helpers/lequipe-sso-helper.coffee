module.exports = class LequipeSSOHelper
  # params : hash
  #   username : string
  #   password : string
  # no checsum decode + params encode
  @login: (params, success, error) ->
    order = ['username', 'password']
    callback = (response) ->
      success?($.parseJSON($('description', response).text()))
    @request 'plac_login', params, yes, order, callback, error

  # params : hash
  #   username : string
  #   password : string
  # no checsum decode + params encode
  @register: (params, success, error) ->
    order = ['email', 'username', 'password', 'gender', 'first_name', 'last_name', 'dateofbirth', 'opt_in_1', 'opt_in_2']
    @request 'plac_register', params, yes, order, success, error

  # params : hash
  #   username : string
  #   email    : string
  # no utf8
  @alreadyUsed: (params, success, error) ->
    order = ['email', 'username']
    @request 'plac_already_used', params, no, order, success, error

  @calculateChecksum : (params, order) ->
    values = ''
    values += params[f] for f in order when params[f]?
    console.log "values", values
    CryptoJS.MD5('efr-plac' + values).toString()

  # fn : string : sso/plac function name
  @request: (fn, params, encode, order, success, error) ->
    params.checksum = @calculateChecksum params, order
    if encode
      params[k] = @utf8_encode(v) for k,v of params
    url = "http://api.lequipe.fr/Compte/appels_tiers.php?F=#{fn}"
    console.log "request"
    console.log url
    console.log params
    $.ajax
      type      : 'POST'
      url       : url
      data      : params
      dataType  : 'xml'
      success   : success
      error     : (xhr, errorType, err) ->
        console.log 'error', arguments

  @utf8_encode = (str_data) ->
    unescape(encodeURIComponent(str_data))

# LequipeSSOHelper = require('helpers/lequipe-sso-helper');var params = {'email':'sdfdf@sdfsddff42.com', 'username':'_-.àáâãäçèéêëìíîïñòóõöùúûü@?£%', 'password':'ssopue', 'gender':1, 'first_name':'john', 'last_name':'doe', 'dateofbirth':'2013-12-12', 'opt_in_1':0, 'opt_in_2':1};;LequipeSSOHelper.register(params);
    #var params = {'email':'sdfdf@sdfsdf.com', 'username':'grossemerde', 'password':'ssopue', 'gender':1, 'first_name':'john', 'last_name':'doe', 'dateofbirth':'2013-12-12', 'opt_in_1':0, 'opt_in_2':1};