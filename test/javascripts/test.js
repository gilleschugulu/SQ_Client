(function(/*! Brunch !*/) {
  'use strict';

  var globals = typeof window !== 'undefined' ? window : global;
  if (typeof globals.require === 'function') return;

  var modules = {};
  var cache = {};

  var has = function(object, name) {
    return ({}).hasOwnProperty.call(object, name);
  };

  var expand = function(root, name) {
    var results = [], parts, part;
    if (/^\.\.?(\/|$)/.test(name)) {
      parts = [root, name].join('/').split('/');
    } else {
      parts = name.split('/');
    }
    for (var i = 0, length = parts.length; i < length; i++) {
      part = parts[i];
      if (part === '..') {
        results.pop();
      } else if (part !== '.' && part !== '') {
        results.push(part);
      }
    }
    return results.join('/');
  };

  var dirname = function(path) {
    return path.split('/').slice(0, -1).join('/');
  };

  var localRequire = function(path) {
    return function(name) {
      var dir = dirname(path);
      var absolute = expand(dir, name);
      return globals.require(absolute);
    };
  };

  var initModule = function(name, definition) {
    var module = {id: name, exports: {}};
    definition(module.exports, localRequire(name), module);
    var exports = cache[name] = module.exports;
    return exports;
  };

  var require = function(name) {
    var path = expand(name, '.');

    if (has(cache, path)) return cache[path];
    if (has(modules, path)) return initModule(path, modules[path]);

    var dirIndex = expand(path, './index');
    if (has(cache, dirIndex)) return cache[dirIndex];
    if (has(modules, dirIndex)) return initModule(dirIndex, modules[dirIndex]);

    throw new Error('Cannot find module "' + name + '"');
  };

  var define = function(bundle, fn) {
    if (typeof bundle === 'object') {
      for (var key in bundle) {
        if (has(bundle, key)) {
          modules[key] = bundle[key];
        }
      }
    } else {
      modules[bundle] = fn;
    }
  };

  globals.require = require;
  globals.require.define = define;
  globals.require.register = define;
  globals.require.brunch = true;
})();

window.require.register("test/controllers/login-controller-test", function(exports, require, module) {
  var Login;

  Login = require('controllers/login-controller');

  describe('Login', function() {
    return beforeEach(function() {
      return this.controller = new Login();
    });
  });
  
});
window.require.register("test/controllers/more-games-controller-test", function(exports, require, module) {
  var MoreGames;

  MoreGames = require('controllers/more-games-controller');

  describe('MoreGames', function() {
    return beforeEach(function() {
      return this.controller = new MoreGames();
    });
  });
  
});
window.require.register("test/controllers/player-controller-test", function(exports, require, module) {
  var Player;

  Player = require('controllers/player-controller');

  describe('Player', function() {
    return beforeEach(function() {
      return this.controller = new Player();
    });
  });
  
});
window.require.register("test/controllers/profile-controller-test", function(exports, require, module) {
  var Profile;

  Profile = require('controllers/profile-controller');

  describe('Profile', function() {
    return beforeEach(function() {
      return this.controller = new Profile();
    });
  });
  
});
window.require.register("test/models/player-test", function(exports, require, module) {
  var Player;

  Player = require('models/player');

  describe('Player', function() {
    return beforeEach(function() {
      return this.model = new Player();
    });
  });
  
});
window.require.register("test/test-helpers", function(exports, require, module) {
  var chai, sinonChai;

  chai = require('chai');

  sinonChai = require('sinon-chai');

  chai.use(sinonChai);

  module.exports = {
    expect: chai.expect,
    sinon: require('sinon')
  };
  
});
window.require.register("test/views/header-view-test", function(exports, require, module) {
  var HeaderView, HeaderViewTest, mediator, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  HeaderView = require('views/header-view');

  mediator = require('mediator');

  HeaderViewTest = (function(_super) {
    __extends(HeaderViewTest, _super);

    function HeaderViewTest() {
      _ref = HeaderViewTest.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    HeaderViewTest.prototype.renderTimes = 0;

    HeaderViewTest.prototype.render = function() {
      HeaderViewTest.__super__.render.apply(this, arguments);
      return this.renderTimes += 1;
    };

    return HeaderViewTest;

  })(HeaderView);

  describe('HeaderView', function() {
    beforeEach(function() {
      return this.view = new HeaderViewTest;
    });
    afterEach(function() {
      return this.view.dispose();
    });
    return it('should display 4 links', function() {
      return expect(this.view.$el.find('a')).to.have.length(4);
    });
  });
  
});
window.require.register("test/views/home-page-view-test", function(exports, require, module) {
  var HomePageView;

  HomePageView = require('views/home-page-view');

  describe('HomePageView', function() {
    beforeEach(function() {
      return this.view = new HomePageView;
    });
    afterEach(function() {
      return this.view.dispose();
    });
    return it('should auto-render', function() {
      return expect(this.view.$el.find('img')).to.have.length(1);
    });
  });
  
});
window.require.register("test/views/login-view-test", function(exports, require, module) {
  var LoginView;

  LoginView = require('views/login-view');

  describe('LoginView', function() {
    return beforeEach(function() {
      return this.view = new LoginView();
    });
  });
  
});
window.require.register("test/views/more-games-view-test", function(exports, require, module) {
  var MoreGamesView;

  MoreGamesView = require('views/more-games-view');

  describe('MoreGamesView', function() {
    return beforeEach(function() {
      return this.view = new MoreGamesView();
    });
  });
  
});
window.require.register("test/views/profile-view-test", function(exports, require, module) {
  var ProfileView;

  ProfileView = require('views/profile-view');

  describe('ProfileView', function() {
    return beforeEach(function() {
      return this.view = new ProfileView();
    });
  });
  
});
window.require.register("test/views/tutorial-view-test", function(exports, require, module) {
  var TutorialView;

  TutorialView = require('views/tutorial-view');

  describe('TutorialView', function() {
    return beforeEach(function() {
      return this.view = new TutorialView();
    });
  });
  
});
window.require('test/controllers/login-controller-test');
window.require('test/controllers/more-games-controller-test');
window.require('test/controllers/player-controller-test');
window.require('test/controllers/profile-controller-test');
window.require('test/models/player-test');
window.require('test/views/header-view-test');
window.require('test/views/home-page-view-test');
window.require('test/views/login-view-test');
window.require('test/views/more-games-view-test');
window.require('test/views/profile-view-test');
window.require('test/views/tutorial-view-test');
