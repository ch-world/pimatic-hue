pimatic-hue
===========

Plugin to control Philipps hue bulbs

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

hueId is the ID of the bulb on the bridge. If you start pimatic with debug turned on 
the plugin will output all bulbs with their IDs.

Limitations
-----------

This plugin is beta and work in progress. At the moment you can only control the brightness and the on/off state of your bulbs. As I don't own any color bulbs yet I'm unable to test code for controlling the color.
