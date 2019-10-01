# pixel-coffee
A tiny LÖVE framework to help to start and debug projects

### TODO: ###

 - [x] Scene editor/Tilemap editor
 - [x] Tileset editor
 - [x] Animation editor
 - [x] Resources viewer
 - [x] Log
 - [ ] Console
 - [ ] Debug
 - [x] Resources manager
 - [x] Scene manager
 - [ ] Pre made shaders
 - [ ] Metroidvania mode for scene editor
 - [ ] Simple audio player
 - [x] Realtime debug
 - [ ] Project preferences
 - [ ] ~~LoveTypescript version (?)~~
 - [ ] ~~Moonscript version (?)~~

### Dependencies: ###

 * love-imgui (fork): https://github.com/canoi12/love-imgui
 * lume: https://github.com/rxi/lume
 * lurker (fork): https://github.com/canoi12/lurker

### How to use: ###

Just include `pixcof` folder and `imgui.so` in your project folder.
And run `love (project_folder) -debug` to open the editor

If you download this repo template, just use yarn:
 - `yarn start` to run game
 - `yarn debug` to run the editor


### Gifs ###

![Imgur](https://i.imgur.com/ibA7IVL.gif)
Some Features

![Imgur](https://i.imgur.com/EO8QLSN.gif)
Entity-Component system