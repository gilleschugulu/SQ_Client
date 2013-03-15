var MessageError = {
  CANT_SEND_TEXT                : 0,
  CANCELLED                     : 1,
  FAILED                        : 2,
  UNKNOWN                       : 3,
  CANT_SEND_MAIL                : 4,
  COULD_NOT_SEND_MAIL           : 5,
  COULD_NOT_SAVE_MAIL_TO_DRAFTS : 6
};

var Message = {
  canSendText : false,
  canSendMail : false,

  // recipients : array of phone numbers
  composeMessage : function(recipients, body, success, fail) {
    Cordova.exec(success, fail, "Message", "composeMessage", [{recipients:recipients, body:body}]);
  },

/*
  var mailObject = {
    subject : "Hello",
    to  : ["someone@mail.com", "blabla@yahoo.com"],
    cc  : ["someone@mail.com", "blabla@yahoo.com"],
    bcc : ["someone@mail.com", "blabla@yahoo.com"],
    body: "How are you ?",
    html: false // is html body or not
  }
*/
  composeMail : function(mailObject, success, fail) {
    Cordova.exec(success, fail, "Message", "composeMail", [mailObject]);
  },

  checkCanSendText : function(success, fail) {
    var self=this;
    var can = function(params) {
      self.canSendText = true;
      if (typeof success !== "undefined")
        success(params);
    }
    Cordova.exec(can, fail, "Message", "canSendText", []);
  },

  checkCanSendMail : function(success, fail) {
    var self=this;
    var can = function(params) {
      self.canSendMail = true;
      if (typeof success !== "undefined")
        success(params);
    }
    Cordova.exec(can, fail, "Message", "canSendMail", []);
  },
};
