# #my-device configuration options
# http://json-schema.org/documentation.html
module.exports ={
  title: "pimatic-my-plugin device config schemas"
  HueBulb: {
    title: "HueBulb config options"
    type: "object"
    properties:
      hueId:
        description: "The ID"
        type: "number"
  }
}