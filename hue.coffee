# #Plugin template

# This is an plugin template and mini tutorial for creating pimatic plugins. It will explain the 
# basics of how the plugin system works and how a plugin should look like.

# ##The plugin code

# Your plugin must export a single function, that takes one argument and returns a instance of
# your plugin class. The parameter is an envirement object containing all pimatic related functions
# and classes. See the [startup.coffee](http://sweetpi.de/pimatic/docs/startup.html) for details.
module.exports = (env) ->

  # ###require modules included in pimatic
  # To require modules that are included in pimatic use `env.require`. For available packages take 
  # a look at the dependencies section in pimatics package.json

  # Require the  bluebird promise library
  Promise = env.require 'bluebird'

  # Require the [cassert library](https://github.com/rhoot/cassert).
  assert = env.require 'cassert'

  # Include you own depencies with nodes global require function:
  #  
  #     someThing = require 'someThing'
  #  
  HueApi = require 'hue-module'

  # ###MyPlugin class
  # Create a class that extends the Plugin class and implements the following functions:
  class Hue extends env.plugins.Plugin

    # ####init()
    # The `init` function is called by the framework to ask your plugin to initialise.
    #  
    # #####params:
    #  * `app` is the [express] instance the framework is using.
    #  * `framework` the framework itself
    #  * `config` the properties the user specified as config for your plugin in the `plugins` 
    #     section of the config.json file 
    #     
    # 
    init: (app, @framework, @config) =>
      env.logger.info("Hue loaded")

      deviceConfigDef = require("./device-config-schema")

      @framework.deviceManager.registerDeviceClass("HueBulb", {
        configDef: deviceConfigDef.HueBulb, 
        createCallback: (config) => new HueBulb(config)
      })

      host = @config.host
      key = @config.apiKey

      HueApi.load host, key

      HueApi.lights (result) =>
        env.logger.info(result)


  class HueBulb extends env.devices.DimmerActuator

    # ####constructor()
    # Your constructor function must assign a name and id to the device.
    constructor: (@config) ->
      @name = @config.name
      @id = @config.id
      @hueId = @config.hueId
      super()

    changeDimlevelTo: (state) ->
      level = Math.round state * 254 / 100

      if level > 0
        HueApi.light @hueId, (light) =>
          HueApi.change light.set({"bri": level, "on": true})

      if level == 0
        env.logger.info(level)
        HueApi.light @hueId, (light) =>
          HueApi.change light.set({"on": false})
      return

  # ###Finally
  # Create a instance of my plugin
  myPlugin = new Hue
  # and return it to the framework.
  return myPlugin