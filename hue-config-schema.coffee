# #my-plugin configuration options
# Declare your config option for your plugin here. 
module.exports = {
  title: "Hue plugin config options"
  type: "object"
  properties:
    apiKey:
      description: "Hue API key"
      type: "string"
    host:
      description: "Address of Hue Bridge"
      type: "string"
    polling:
      description: "Polling Intervall"
      type: "integer"
      default: 10000
}