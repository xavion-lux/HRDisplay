### Changelog

This release aim at facilitating the use of the shader with already existing OSC solutions for VRChat and to mitigate the lack of precision when using a single float value to set the heart rate.

- Renamed HRDisplay to HRDisplaySingle (because it only uses one property to set the value)
- Replaced HRDisplay with new version better adapted for use with existing OSC softwares for VRChat
  - Added `_Hundreds`, `_Tens` and `_Units` properties to HRDisplay
- Renamed files in package
- Updated README
