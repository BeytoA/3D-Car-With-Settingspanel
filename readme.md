![Asset Thumbnail](icon196x196.png?raw=true)
# 3D Car with Settingspanel

This asset contains a driveable car which you can directly use in your project. All you need to do is to drag and drop the `car.tscn` file into your scene. Once you are done, you could press `**ESC**` to open the `SettingsPanel` to adjust the `VehicleBody` and all the `Wheel` nodes individually. Main focus of this asset is to make a quick start with cars in Godot and save all the vehicle settings you have made for later use. This can be done by the built-in preset system in this asset.

## Getting Started

The car scene is created for common use with a `VehicleBody` as a top node. The body consists a single mesh including the mainframe, windows and lights. For the best performance, `CollisionShape` is a `BoxShape` with approximate size of the body mesh.

### How to use
You need to copy the `3d_car_customizable` folder into your project. You are now ready to go. Simply instance the `car.tscn` scene to where you need it and start the project.

![Screenshot](screenshot2.png?raw=true)

Simply control the car with the arrow keys and press `**ESC**` to open the `Settingspanel`. Here, you can adjust several settings of the car. `ScriptVariables` and `VehicleBody` are general car settings. After them, you can see `rear_left`, `rear_right`, `front_right` and `front_left` labels presenting each `Wheel` node. Sliders apply the values immediately on the car. You can save these settings by pressing on the `Save Preset` button at the top of the panel. A preset name should be written in the `LineEdit` next to the button.

A preset is located in the `user://3d_car_customizable/` folder. All the presets in this folder are listed in the `Preset List` on launch. The first preset on this list will be loaded automatically when the node enters the tree.

#### Asset Settings

- [x] `Use Camera` attaches a camera on the hood.
- [x] `Use Controls` lets you control the car with arrow keys.
- [x] `Show Settings` will show Settingspanel when `**ESC**` is pressed. *Does not disable preset system*

### Car Model
![Car Model](screenshot1.png?raw=true)

I have modeled a car with Blender for this tutorial. You have the full rights of the car model. If you would like to model your own, it is really easy I would say. Just follow [CGGeek's Low Poly Vehicle Modeling Tutorial here](https://www.youtube.com/watch?v=Zkg7Ol2jEjs).

## Features
* Fully working car
* Can be controlled with keyboard (`ui` keymaps)
* A camera placed on the hood
* Turn the camera with mouse movements
* Decent `VehicleBody` and `Wheel` properties applied
* Settingspanel for tuning the car
* **Built-in preset system**
* Bind wheelsettings to each other
* Load first preset on the list automatically on launch

## Known Issues
If you instance 2 cars in a single scene and you want to switch between them, you need to code it yourself to control the cars independently.
The idea was to place the camera at the back of the car like the most racing games. I have come across some problems where I was forced to place the camera on the hood.
You can not disable preset system. It will load the first preset on launch if there is one.

## Contributing
You are free to make suggestions on this asset. I would love to impletement new features, improve the current ones and make the code more organized.

## Licence
This asset is licenced under the CC0 1.0 Universal (CC0 1.0) Public Domain Dedication - see the [LICENSE.md](LICENSE.md) file for details. You could simply use this asset in your projects and not mention anyone or anything. It is completely free to use/change/sell.
