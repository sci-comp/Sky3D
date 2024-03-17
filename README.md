# Time Of Day

A dynamic day/night cycle for Godot Engine 4, written in GDScript.

## Features
* Supports Godot 4.2, may work with other versions
* Auto rotating sun, moon, and stars
* Dynamic clouds
* Fog and cloud color responds to the sun and moon


## Status

This plugin was originally written for Godot 3 in GDScript and C# by J. Cuéllar. The original repository was lost, but we have revived and ported it to Godot 4.

Currently, the GDScript version works fine. The original C# version is untouched and unsupported. Contributors are encouraged to follow the GDScript changes to update and maintain the C# version. Otherwise, we may remove it from the repository.

## Installation
* Clone or download the repository. 
* Create a directory in your project called addons.
* Copy `addons/jc.godot.time-of-day` and `addons/jc.godot.time-of-day-common` into your project `addons` directory.
* Go to `Project -> Project Settings -> Plugins` and enable the plugin. 


## Usage

* Create or open a Scene to house your environment
* Create a new node of type `SkyDome`
* Create a new node of type `TimeOfDay`. Neither node needs to be a child of the other.
* Click `TimeOfDay`, and in the inspector, under Target, set `dome_path` and connect it to the SkyDome node.
* Under `Planetary and Location`, enable `compute_moon_coords` **TODO enable by default**
* Add a WorldEnvironment node, and change `Tonemap/mode` to `Filmic` or `ACES` and increase `White` to 4+.
* Don't overexpose your exposure, camera, or other lights.


## Notes
These are from v3, which may be out of date
* Optimal reflections are possible with a well-configured reflection probe. 
* The reflection probe can produce artifacts if the intensity of the sun is very high. 
* You can only get reflections with a reflection probe. GI is unknown.
* The sky model and clouds does not have support for altitude variation. 


## Credit
Developed for the Godot community by:
|||
|--|--|
| Original Godot 3 version by ||
| **J. Cuéllar** | [<img src="https://github.com/dmhendricks/signature-social-icons/blob/master/icons/round-flat-filled/35px/twitter.png?raw=true" width="24"/>](https://twitter.com/JayKuellar) 
| Ported to Godot 4 by ||
| **Cory Petkovsek, Tokisan Games** | [<img src="https://github.com/dmhendricks/signature-social-icons/blob/master/icons/round-flat-filled/35px/twitter.png?raw=true" width="24"/>](https://twitter.com/TokisanGames) [<img src="https://github.com/dmhendricks/signature-social-icons/blob/master/icons/round-flat-filled/35px/github.png?raw=true" width="24"/>](https://github.com/TokisanGames) [<img src="https://github.com/dmhendricks/signature-social-icons/blob/master/icons/round-flat-filled/35px/www.png?raw=true" width="24"/>](https://tokisan.com/) [<img src="https://github.com/dmhendricks/signature-social-icons/blob/master/icons/round-flat-filled/35px/discord.png?raw=true" width="24"/>](https://tokisan.com/discord) [<img src="https://github.com/dmhendricks/signature-social-icons/blob/master/icons/round-flat-filled/35px/youtube.png?raw=true" width="24"/>](https://www.youtube.com/@TokisanGames)|
| **Roman Shapiro** | [<img src="https://github.com/dmhendricks/signature-social-icons/blob/master/icons/round-flat-filled/35px/github.png?raw=true" width="24"/>](https://github.com/rds1983)

## License

MIT License

If using the stars asset, you must [credit the author](https://github.com/TokisanGames/TimeOfDay/blob/main/addons/jc.godot.time-of-day-common/Assets/ThirdParty/Graphics/Textures/MilkyWay/Credits.md).

 **TODO what about star field and moon map?**
