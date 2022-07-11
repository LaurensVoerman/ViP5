# ViP
[![CC BY 4.0][cc-by-shield]][cc-by]
This work is licensed under a
[Creative Commons Attribution 4.0 International License][cc-by].
[![CC BY 4.0][cc-by-image]][cc-by]

[cc-by]: http://creativecommons.org/licenses/by/4.0/
[cc-by-image]: https://i.creativecommons.org/l/by/4.0/88x31.png
[cc-by-shield]: https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg

Virtuele Practica



## Introduction

![icon](https://github.com/LaurensVoerman/ViP/blob/main/Build/Android/res/drawable-xhdpi/icon.png?raw=true)

The ViP package is an unreal project that allows students to practice building a chemstry setup in VR on the oculus quest or quest2 vr headset. While the project works on a pc connected rift of trough oculus link, that is not the intended target (it is usefull for debugging). In the current state the project will NOT work without VR controllers, because no interaction is possible with keyboard/mouse.
As this is a "blueprint only" project, Visual Studio should not be required.

## Software environment

The current project builds on windows 10 (21H1) with
Unreal Engine 4.26.2
with the following plugins:
- Blueprint File SDK https://www.unrealengine.com/marketplace/en-US/product/blueprint-file-sdk
- VaRest 1.1-r31 https://www.unrealengine.com/marketplace/en-US/product/varest-plugin
- Oculus VR plugin v 1.51.0 

#### To build the Android ASTC target for the quest(2) the following software is needed:

- Android Studio 4.0 from https://developer.android.com/studio/archive
    setup instructions here: https://docs.unrealengine.com/4.26/en-US/SharingAndReleasing/Mobile/Android/Setup/AndroidStudio/

- Oculus Link: https://www.oculus.com/setup/
- Oculus ADB Drivers: https://developer.oculus.com/downloads/package/oculus-adb-drivers/

#### Project start
* Load Errors: Failed to load /Game/VirtualRealityBP/Maps/MotionControllerMap_BuiltData.MotionControllerMap_BuiltData Referenced by PersistentLevel  
    - the BuildData is not in the reposetory; press "Build" in the editor to generate it.
* while building: droogbuis Object has overlapping UVs (~12x).
    - to be fixed.

#### Build Android_ASTC
as my android keystore (build/Android/KeyStore.jks)is not included in the github files, you may need to create your own keystore:
In the Unreal editor: navigate to Edit -> Project Settings; Platforms - Android under "Distribution Signing" is a link with instructions.
* update: edit->Project Settings Packaging “For Distribution” OFF  
committed to github to make project build unsigned and without errors.

for the quest for business you may want to generate the SHA256 checksum:

    certutil -hashfile Schlenklijn-Android-Shipping-arm64.apk SHA256  
    certutil -hashfile main.1.com.YourCompany.Schlenklijn.obb SHA256  

## game objects
The majority of the game objects are objects of blueprint class "BP_PickupCube" (VirtualRealityBP\Blueprints\BP_PickupCube)
the different meshes (eg glassware\connectors\stop_yellow) have "sockets" with a name (yellow.in for stop_yellow).
These sockets will match opposing sockets in other pieces, and connect to them.

* yellow.(in|out) = standard taper 14/23 ground glass [Conically tapered joints](https://en.wikipedia.org/wiki/Ground_glass_joint#Conically_tapered_joints)
* green.(in|out) = standard taper 24/29 ground glass Conically tapered joints
    - when connecting these types of socket, only the rotation about the socket z-axis is taken from the dropped objects' current relative postition, translation and the other orientation is taken from the matching socket.
#### Other socket types:
* yellow.clip intended for 14 mm [plastic joint clip](https://en.wikipedia.org/wiki/Joint_clip#Plastic_joint_clips), 
* green.clip intended for 24 mm plastic joint clip
    - In the game logic these clips will stop the glassware from seperating until the clip is removed
* tube.in - barbed connector for 6 mm tubes.
* rail.(in|out) - invisible sliding rail; fixed orientation on matching socket, but free z-axis position.
* Cyl_40mm.(in|out) - intended for a glass clamp (something like [this](https://en.wikipedia.org/wiki/Utility_clamp) )
* Cyl_10mm.(in|out) - intended for steel rods of labstand and glass clamp matching a bosshead
    - Cyl* sockets allow rotation and translation about the z-axis;
    - Cyl*.in sockets can have multiple connections if they have different translation.
* 2waytap.(in|out) glass or plastic rotating tap with a single horizontal hole.
* 3waytap.(in|out) glass rotating tap with two slanted holes.
* (2|3)waytap.clip blue plastic screwcap fixing taps in place. 
  When clipped with this cap, the tap will only rotate in it's socket when grabbed.
* dial.in - used in the stirrer, this type of dial allows for limited rotatation. (0.9 full rotations =324 degrees)
* 1waytap.in - used in fixed scene (Content\Geometry\zuurkast_main_zonderknoppen); not used for in game dynamic matching
* PermanentlyAttached - connected to 1waytap.in in fixed scene (Content\Geometry\zuurkast_kraan_knob*) ; allows 2 full rotations about z
* 0waytap.out - used for the labjack control knob; allows 11.68 full rotations.
* roerboon.(in|out) stirring bean connector; should be available in all fluid containgers, not yet driven by magnetic stirrer.
    
glass material: The glass material used comes from this (free) unreal assed pack https://www.unrealengine.com/marketplace/en-US/product/advanced-glass-material-pack

## blueprint code
##### VirtualRealityBP/Blueprints/BP_PickupCube
provides most glassware behavior: highlight on select, pickup & drop; find matching sockets on drop and attach.
###### VirtualRealityBP/Blueprints/BP_Labjack
derives from pickupCube, has a construction script and responds to "socket value changed" by changing it's height.
###### VirtualRealityBP/Blueprints/BP_RemoteController
spawned when grabbing a rotating tap, reduces the current controller transform to a rotation, adds rotation from thumb joystick and passes the movement to the tap as "socket value changed" message, making the tap move.
###### VirtualRealityBP/Blueprints/BP_RailRemoteController
like the remoteController - but this one dous translation (used for sliding glass front of the fumehood)
###### glassware/TubeEnd

##### glassware/Tube1
provide fexible tubes connecting cooling and lab gasses. spwans a tubeEnd start and endpoint that connects to "tube.in" sockets.
##### Button/BP_VRPushButton
reset/load/save buttons. provides access to a single savegame, stored on the quest in
/sdcard/UE4Game/Schlenklijn/Schlenklijn/Saved/SaveGames/DefaultSlot.sav
(windows: Schlenklijn\Saved\SaveGames\DefaultSlot.sav)
As this savegave persists across reboots, this allows you to stop the app and even restart the quest to get the chromecast working again without losing your current work.
##### Button/MySaveGame
Load/Save functions

##### VirtualRealityBP/Blueprints/BP_LabGameMode
Game mode - data only
##### VirtualRealityBP/Blueprints/BP_MotionController
default from Startercontent; modified
* Release Actor: don't drop something taken by the other hand
* Setup Room Scale Outline: disabled to remove reference to SteamVRChaperone requiring steamVR plugin
* EventGraph Tick: after "update animation of hand" add highlight code to show grab target.

##### VirtualRealityBP/Blueprints/MotionControllerPawn
default from Startercontent
##### VirtualRealityBP/Blueprints/PickupActorInterface
default from Startercontent; defines interface function "Pickup" and "Drop"
##### VirtualRealityBP/Blueprints/WebPageWidget
TBD: currently doesn't work at all.
##### VirtualRealityBP/Blueprints/InfoText
TBD: disabled; intened to allow config file to load on startup to change instructions and available parts.

