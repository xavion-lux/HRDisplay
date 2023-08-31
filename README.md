# HRDisplay

![GitHub release (latest by date)](https://img.shields.io/github/v/release/xavion-lux/HRDisplay?style=flat-square)
![License](https://img.shields.io/github/license/xavion-lux/HRDisplay?style=flat-square)
![GitHub all releases](https://img.shields.io/github/downloads/xavion-lux/HRDisplay/total?style=flat-square)

HRDisplay is a custom shader written in HLSL for Unity's built-in render pipeline, designed to display the user's heart rate along with an animated heart beating at the same pace. The shader is primarily created for use in VRChat but can be adapted for other Unity projects as well.

<details>
  <summary>Table of Contents</summary>
  <ul>
    <li><a href="#preview">Preview</a></li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#usage">Usage</a></li>
        <li><a href="#customization">Customization</a></li>
	      <li><a href="#installation-for-vrchat">Installation for VRChat</a></li>
      </ul>
    </li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#license">License</a></li>
  </ul>
</details>

## Preview

![Unity_d5PY0tkmWQ](https://github.com/xavion-lux/HRDisplay/assets/57081039/5706b1b9-9f7b-425b-98ee-8c66c4a4c87e)

## Getting Started

### Usage

This shader is primarily designed to be used with other projects like [VRCOSC](https://github.com/VolcanicArts/VRCOSC) or [Pulsoid-to-VRChat-OSC](https://github.com/Sonic853/pulsoid-to-vrchat-osc) to control avatar parameters with OSC.</br>
For installation on VRChat avatars, skip to [Installation for VRChat](#installation-for-vrchat).

Two variants of the shader exist. One controlled with a single property, `HRDisplaySingle`, and `HRDisplayTriple` with 3 properties, one for each decimal place. Choose the easiest version to set up with your environment.

The display can be controlled using the `Hundreds`, `Tens` and `Units` material properties or the `BPM` property depending on which variant of the shader you use.

### Customization

You can customize the shader by providing your own textures for the heart as well as the numbers.</br>
A template for the number texture is provided for you to create your own number textures.

## Installation for VRChat

https://github.com/xavion-lux/HRDisplay/assets/57081039/a63f4dfc-e889-45bc-82c7-208bb04bc0f4

<ol>
  <li>Import <a href="https://modular-avatar.nadena.dev">Modular Avatar</a> in your already existing project with the VRChat Creator Companion or by downloading the latest release from <a href="https://github.com/bdunderscore/modular-avatar/releases/latest">here</a>.</li>
  <li>Download and import the latest release of HRDisplay from <a href="https://github.com/xavion-lux/HRDisplay/releases/latest">here</a>.</li>
  <li>Go to the VRChat folder in HRDisplay and drag and drop the one of the prefab (using one or three parameters to control the display) to the desired location in your armature.</li>
  <li>Move and resize the display to your liking.</li>
  <li>You're avatar is now ready for upload! Modular Avatar will take care of merging the FX layers and parameters when uploading automatically, without permanently modifying your avatar.</li>
</ol>

If you experience issues with your textures from a long distances double check the mipmap settings for your texture in Unity.

## Contributions

This is my first shader, made as a small side-project. It is hand-written from scratch in HLSL so there is probably room for various improvements.</br>
Contributions to the project are therefore welcome.

## License

HRDisplay is licensed under the [AGPLv3 License](LICENSE). You are free to use, modify, and distribute the shader as per the terms and conditions of the license.

"heart.png" from "[small-n-flat](https://github.com/paomedia/small-n-flat)" by [Paomedia](https://github.com/paomedia) is licensed under [CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/).
