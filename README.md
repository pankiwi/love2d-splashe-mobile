splashes [![join on gitter](https://badges.gitter.im/love2d-community/splashes.svg)](https://gitter.im/love2d-community/splashes) [![LOVE](https://img.shields.io/badge/L%C3%96VE-0.10.1-EA316E.svg)](http://love2d.org/)
========
Is a simple splash screen for LÖVE on based [original version](https://github.com/love2d-community/splashes)

Run this repo with `love .` to check out all splash screens.
Press any key to skip ahead.

 ## preview
 
 ![preview](/preview.png)
 
Usage
-----
Pick the splash you want to use from our wide variety of **1** (*one*) splashes and move the directory somewhere into your project.
Require the file and instantiate the splash using `splash.new()`.
Make sure to hook the love callbacks up to `splash:update(dt)` and `splash:draw()` and call `splash:skip()` to let the player skip the splash.

```lua
local simple_o_ten_one = require "simple-o-ten-one"

function love.load()
  splash = simple_o_ten_one()
  splash.onDone = function() print "DONE" end
end

function love.update(dt)
  splash:update(dt)
end

function love.draw()
  splash:draw()
end

function love.keypressed()
  splash:skip()
end
```

Splash Interface
----------------

The library only has one function you should use:

### `lib.new(...)`
Instantiate a new `splash`.
You can also do this by calling the library itself: `lib(...)`.
Accepts a table with parameters depending on the specific splash (see below).

The following members of the `splash` variable are of importance to you as a user:

### `splash:update(dt)`
Update the splash.

### `splash:draw()`
Draw the splash.

### `splash:skip()`
Skip the splash.
Splash may still run an exit transition after this, wait for the `onDone()` callback to fire.

### `splash.onDone()`
A callback you can add on the `splash` table.
Gets called when the splash exits or is skipped.

Splashes
--------

### `simole-o-ten-one`
`new()` parameters:

* `background`: `{r,g,b}` table used to clear the screen with.
  Set to `false` to draw underneath. Dafaults color `{.42, .75, .89}`

  Example: _Setting a pink background color_

  ```lua
  splash = lib.new({background={255,0,255}})
  ```
  
* `delayBefore`: number of seconds to delay before the animation.
  Defaults to `0.3`.

* `delayAfter`: number of seconds to delay before the animation.
  Defaults to `0.7`.

  Example: _Custom settings_
  ```lua
  splash = lib({
    --purple
    background = {146/255, 14/255, 253/255},
    -- 0.4s
    delayBefore = 0.4,
    -- 0.1s
    delayAfter = 0.1
  })
  ```