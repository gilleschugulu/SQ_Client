module.exports = class LequipeSSOHelper
  @error = {}
  # params : hash
  #   username : string
  #   password : string
  # no checsum decode + params encode
  @login: (params, success, error) ->
    order = ['username', 'password']
    callback = (response) =>
      mapping =
        nom   : 'last_name'
        prenom: 'first_name'
      response = @xmlResponse2JSON response
      user = $.parseJSON(response.description)
      user = @remap user, mapping
      success?(user)
    @request 'plac_login', params, yes, order, callback, error
  @error.login =
    INCORRECT_MAIL    : 404
    INCORRECT_PASSWORD: 403

  # params : hash
  #   username : string
  #   password : string
  #   gender : enum(0,1) : 1 = Mme, 0 = M
  # no checsum decode + params encode
  @register: (params, success, error) ->
    order = ['email', 'username', 'password', 'gender', 'first_name', 'last_name', 'dateofbirth', 'opt_in_1', 'opt_in_2']
    params['opt_in_1'] ?= 0
    params['opt_in_2'] ?= 0
    user = {}
    user[k] = v for k,v of params
    callback = (response) ->
      success?(user)
    @request 'plac_register', params, yes, order, callback, error

  @error.register =
    INVALID_PARAMETERS: 400
    NOT_AVAILABLE     : 409

  # params : hash
  #   username : string
  #   email    : string
  # no utf8
  @alreadyUsed: (params, success, error) ->
    order = ['email', 'username']
    callback = (response) =>
      mapping =
        email   : 'email'
        pseudo  : 'username'
        civilite: 'gender'
        nom     : 'last_name'
        prenom  : 'first_name'
      user = @xmlResponse2JSON response
      user = @remap user, mapping
      success?(user)
    @request 'plac_already_used', params, no, order, callback, error
  @error.alreadyUsed =
    MISSING_PARAMETERS  : 400
    USER_NOT_FOUND      : 404
    USED_BY_ANOTHER_USER: 409

  @calculateChecksum : (params, order) ->
    values = ''
    values += params[f] for f in order when params[f]?
    CryptoJS.MD5('efr-plac' + values).toString()

  # fn : string : sso/plac function name
  @request: (fn, params, encode, order, success, error) ->
    params.checksum = @calculateChecksum params, order
    if encode
      params[k] = @utf8_encode(v) for k,v of params
    # url = "http://api.lequipe.fr/Compte/appels_tiers.php?F=#{fn}"
    url = "http://www.lequipe.fr/jeux/chugulu/sso.php?F=#{fn}"
    $.ajax
      type    : 'POST'
      url     : url
      data    : params
      dataType: 'xml'
      success : success
      error   : (xhr, errorType, err) =>
        response = if /<\?xml/.test xhr.responseText then @xmlResponse2JSON(xhr.responseText) else xhr.responseText
        error(xhr.status, response)

  # Utility methods
  # ---------------

  # renames object properties
  @remap: (object, mapping) ->
    remaped = {}
    for k,v of object
      if mapping?[k]?
        remaped[mapping[k]] = v
      else
        remaped[k] = v
    remaped

  @xmlResponse2JSON: (xml) =>
    object = {}
    unless xml instanceof Document
      responseEl = $(xml.replace(/\s*<\?[^\?]+\?>\s*/, ''))
    else
      responseEl = $('response', xml)
    responseEl.children().each (index, item) =>
      el    = $(item)
      tag   = el.prop('tagName').toLowerCase()
      value = @utf8_decode el.text()
      object[tag] = value
    object

  @utf8_encode: (str_data) ->
    unescape(encodeURIComponent(str_data))

  @utf8_decode: (str_data) ->
    string = ""
    i = 0
    c = c1 = c2 = 0
    while i < str_data.length
      c = str_data.charCodeAt(i)
      if c < 128
        string += String.fromCharCode(c)
        i++
      else if (c > 191) and (c < 224)
        c2 = str_data.charCodeAt(i + 1)
        string += String.fromCharCode(((c & 31) << 6) | (c2 & 63))
        i += 2
      else
        c2 = str_data.charCodeAt(i + 1)
        c3 = str_data.charCodeAt(i + 2)
        string += String.fromCharCode(((c & 15) << 12) | ((c2 & 63) << 6) | (c3 & 63))
        i += 3
    string

# LequipeSSOHelper = require('helpers/lequipe-sso-helper');var params = {'email':'sdfdf@sdfsddff42.com', 'username':'_-.àáâãäçèéêëìíîïñòóõöùúûü@?£%', 'password':'ssopue', 'gender':1, 'first_name':'john', 'last_name':'doe', 'dateofbirth':'2013-12-12', 'opt_in_1':0, 'opt_in_2':1};;LequipeSSOHelper.register(params);
    #var params = {'email':'sdfdf@sdfsdf.com', 'username':'grossemerde', 'password':'ssopue', 'gender':1, 'first_name':'john', 'last_name':'doe', 'dateofbirth':'2013-12-12', 'opt_in_1':0, 'opt_in_2':1};