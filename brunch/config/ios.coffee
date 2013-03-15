spawn = require('child_process').spawn
bi    = spawn 'scripts/build_increment.rb', []
bal   = spawn 'scripts/build_assets_list.rb', []

biout = (data) ->
  console.log('Build increment: ' + data)
balout = (data) ->
  console.log('Build assets list : ' + data)
sedout = (data) ->
  console.log('Change environment : ' + data)

# Will parse argument searching for -e=prod or -e=preprod.
# If not found, current env will be local
env_regex = ///-e=(prod|preprod)///
env = 'local'
process.argv.forEach (val, index, array) ->
  if captured = val.match(env_regex)
    env = captured[1]

# Copy environment file to set the asked config.
cp = spawn 'cp', ["app/config/#{env}-config.coffee", 'app/config/environment-config.coffee']

bi.stdout.on 'data', biout
bi.stderr.on 'data', biout
bal.stdout.on 'data', balout
bal.stderr.on 'data', balout
cp.stdout.on 'data', sedout
cp.stderr.on 'data', sedout

exports.config =
  # See http://brunch.readthedocs.org/en/latest/config.html for documentation.
  files:
    javascripts:
      joinTo:
        'javascripts/app.js': /^(app|vendor)(\/|\\)(?!web)/
        'test/javascripts/test.js': /^test[\\/](?!vendor)/
        'test/javascripts/test-vendor.js': /^test[\\/](?=vendor)/
      order:
        # Files in `vendor` directories are compiled before other files
        # even if they aren't specified in order.before.
        before: [
          'vendor/scripts/console-polyfill.js',
          'vendor/scripts/zepto.js',
          'vendor/scripts/underscore-1.4.4.js',
          'vendor/scripts/backbone-0.9.10.js'
        ]
        after: [
          'test/vendor/scripts/test-helper.js'
        ]

    stylesheets:
      joinTo:
        'stylesheets/app.css': /^(app|vendor)/
        'test/stylesheets/test.css': /^test/
      order:
        before: ['vendor/styles/normalize-2.0.1.css']
        after: ['vendor/styles/helpers.css']

    templates:
      joinTo: 'javascripts/app.js'

  server:
    run: no
    port: 3333

  paths:
    public: 'build/ios'
