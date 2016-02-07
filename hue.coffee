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
  # HueApi = require 'hue-module'
  HueApi = require 'philips-hue'
  hueApi = new HueApi()

  # ###MyPlugin class
  # Create a class that extends the Plugin class and implements the following functions:
  class Hue extends env.plugins.Plugin
    # array for notifying HueBulbs on poll
    bulbs: []

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
      username = @config.username
      polling = @config.polling

      hueApi.bridge = host
      hueApi.username = username

      hueApi.lights (err, lights) =>
        env.logger.debug(lights)

      setInterval( ( => @poll() ), polling)

    # add bulb to list for polling
    registerBulb: (bulb) ->
      @bulbs.push bulb

    # function for polling state of bulbs
    # notifys HueBulb about state
    poll: ->
      env.logger.debug("Polling Hue Bulbs")
      hueApi.lights (err, lights) =>
        if err
          env.logger.warn("Error while polling: " + err)
        else
          for bulb in @bulbs
            do (bulb) ->
              bulb.updateState lights[bulb.hueId].state


  class HueBulb extends env.devices.DimmerActuator

    # ####constructor()
    # Your constructor function must assign a name and id to the device.
    constructor: (@config) ->
      @name = @config.name
      @id = @config.id
      @hueId = @config.hueId
      @light = hueApi.light @hueId
      super()
      plugin.registerBulb(this)

    # called by polling for updating the state
    # argument is the current state returned by the bridge
    updateState: (state) ->
      if state.reachable
        if state.on
          level = Math.round state.bri / 254 * 100
        else
          level = 0
      else
        level = 0
      if level != @_dimlevel
        @_dimlevel = level
        @_setState(level > 0)
        @emit 'dimlevel', level

    changeDimlevelTo: (state) ->
      level = Math.round state * 254 / 100

      new Promise (resolve, reject) =>
        if level > 0
          @light.setState {"bri": level, "on": true}, (err, res) =>
            if err
              reject err
            else
              @_setDimlevel(state)
              resolve res
        else
          @light.off (err, res) =>
            if err
              reject err
            else
              @_setDimlevel(state)
              resolve res

  # ###Finally
  # Create a instance of my plugin
  plugin = new Hue
  # and return it to the framework.
  return plugin