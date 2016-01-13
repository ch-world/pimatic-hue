pimatic-hue
===========

Plugin to controll Philipps hue bulbs

Configuration
-------------

You need to create an API key on your bridge to use this plugin. See the [hue developer programm](http://www.developers.meethue.com/documentation/getting-started) for details how to do this.

plugins section:
```
{
  "plugin": "hue",
  "apiKey": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "host": "xxx.xxx.xxx.xxx"
}
```

devices section:
```
{
  "id": "hueBulb1",
  "class": "HueBulb",
  "name": "My first bulb",
  "hueId": 1
}
```

Limitations
-----------

This plugin is beta and work in progress. At the moment you can only controll the brightness and the on/off state of your bulbs. As I don't own any color bulbs yet I'm unable to test code for controlling the color.