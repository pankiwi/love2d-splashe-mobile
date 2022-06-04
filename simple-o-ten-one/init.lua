--is not original version is edit by pankiwi , original version is https://github.com/love2d-community/splashes


local splashlib = {
  _VERSION     = "0.1",
  _DESCRIPTION = "a 0.1 simple splash",
  _URL         = "https://github.com/pankiwi/love2d-splashe-mobile",
  _LICENSE     = [[Copyright (c) 2016 love-community members (as per git commits in repository above)

This software is provided 'as-is', without any express or implied
warranty. In no event will the authors be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

1. The origin of this software must not be misrepresented; you must not
   claim that you wrote the original software. If you use this software
   in a product, an acknowledgement in the product documentation would be
   appreciated but is not required.
2. Altered source versions must be plainly marked as such, and must not be
   misrepresented as being the original software.
3. This notice may not be removed or altered from any source distribution.

The font used in this splash is "Handy Andy" by www.andrzejgdula.com]]
}

local current_module = (...):gsub("%.init$", "")
local current_folder = current_module:gsub("%.", "/")

local timer = require(current_module .. ".timer")

local colors = {
  bg =     {.42, .75, .89},
  white =  {  1,   1,   1},
  blue =   {.15, .67, .88},
  pink =   {.91, .29,  .6},
}

-- patch shader:send if 'lighten' gets optimized away
local function safesend(shader, name, ...)
  if shader:hasUniform(name) then
    shader:send(name, ...)
  end
end

function splashlib.new(settings)
  local self = {}
  local width, height = love.graphics.getDimensions()
  
  self.settings = {
    background = colors.bg,
    delayBefore = 0.3,
    delayAfter = 0.7
  }
  
  setmetatable(self.settings, settings)
  
  -- this shader makes the text appear from left to right
  self.textshader = love.graphics.newShader[[
  extern number alpha;

  vec4 effect(vec4 color, Image logo, vec2 tc, vec2 sc)
  {
    //Probably would be better to just use the texture's dimensions instead; faster reaction.
    vec2 sd = sc / love_ScreenSize.xy;

    if (sd.x <= alpha) {
      return color * Texel(logo, tc);
    }
    return vec4(0);
  }
  ]]

  -- this shader applies a stroke effect on the logo using a gradient mask
  self.logoshader = love.graphics.newShader[[
  //Using the pen extern, only draw out pixels that have their color below a certain treshold.
  //Since pen will eventually equal 1.0, the full logo will be drawn out.

  extern number pen;
  extern Image mask;

  vec4 effect(vec4 color, Image logo, vec2 tc, vec2 sc)
  {
    number value = max(Texel(mask, tc).r, max(Texel(mask, tc).g, Texel(mask, tc).b));
    number alpha = Texel(mask, tc).a;

    //probably could be optimzied...
    if (alpha > 0.0) {
      if (pen >= value) {
        return color * Texel(logo, tc);
      }
    }
    return vec4(0);
  }
  ]]

  self.alpha = 1
  self.heart = {
    sprite = love.graphics.newImage(current_folder .. "/heart.png"),
    scale = 0,
    rot   = 0
  }

  self.stripes = {
    scaleWidth = 0,
  }
  self.upstripes = {
    scaleWidth = 0,
  }

  self.text = {
    obj = love.graphics.newText(love.graphics.newFont(current_folder .. "/handy-andy.otf", 22), "made with"),
    alpha = 0
  }
  self.text.width, self.text.height = self.text.obj:getDimensions()

  self.logo = {
    sprite = love.graphics.newImage(current_folder .. "/logo.png"),
    mask = love.graphics.newImage(current_folder .. "/logo-mask.png"),
    pen  = 0
  }
  self.logo.width, self.logo.height = self.logo.sprite:getDimensions()

  safesend(self.textshader, "alpha", 0)
  safesend(self.logoshader, "pen", 0)
  safesend(self.logoshader, "mask", self.logo.mask)
  
  timer.clear()
  timer.script(function(wait)
    wait(self.settings.delayBefore)
    
    timer.every(0, function()
      safesend(self.textshader, "alpha",   self.text.alpha)
      safesend(self.logoshader, "pen",     self.logo.pen)
    end)
    
    timer.tween(.6, self.stripes, {scaleWidth = 1}, "sine")
    wait(.6)
    -- write out the text
    timer.tween(.75, self.text, {alpha = 1}, "linear")
    timer.tween(.75, self.heart, {scale = 1}, "linear")
    -- draw out the logo, in parts
    local mult = 0.65
    
    local function tween_and_wait(dur, pen, easing)
      timer.tween(mult * dur, self.logo, {pen = pen/255}, easing)
      wait(mult * dur)
    end
    
    tween_and_wait(0.175,  50, "in-quad")     -- L
    tween_and_wait(0.300, 100, "in-out-quad") -- O
    tween_and_wait(0.075, 115, "out-sine")    -- first dot on O
    tween_and_wait(0.075, 129, "out-sine")    -- second dot on O
    tween_and_wait(0.125, 153, "in-out-quad") -- \
    tween_and_wait(0.075, 179, "in-quad")     -- /
    tween_and_wait(0.250, 205, "in-quart")    -- e->break
    tween_and_wait(0.150, 230, "out-cubic")   -- e finish
    tween_and_wait(0.150, 244, "linear")      -- ()
    tween_and_wait(0.100, 255, "linear")      -- R
    wait(0.4)

    -- no more skipping
    wait(self.settings.delayAfter)
    self.done = true
    
    timer.tween(.2, self.stripes, {scaleWidth = 0}, "in-out-sine")
    wait(0.2)
    timer.tween(.4, self.upstripes, {scaleWidth = 1}, "in-sine")
    wait(0.4)
    self.alpha = 0
    self.heart.scale = 0
    wait(0.1)
    timer.tween(.75, self.upstripes, {scaleWidth = 0}, "in-quart")
    wait(1)
    timer.clear()
    if self.onDone then self.onDone() end
  end)

  self.draw = splashlib.draw
  self.update = splashlib.update
  self.skip = splashlib.skip

  return self
end

function splashlib:draw()
  local width, height = love.graphics.getDimensions()
  
  love.graphics.clear(self.settings.background)
  
  love.graphics.push()
  love.graphics.setColor(colors.pink)
  love.graphics.rectangle("fill", 0,0, width/2 * self.stripes.scaleWidth, height )
  love.graphics.setColor(colors.blue)
  love.graphics.rectangle("fill",width, 0, -(width/2 * self.stripes.scaleWidth), height )
  love.graphics.pop()
      
  
  love.graphics.push()
  love.graphics.setColor(1, 1, 1, self.heart.scale)
  love.graphics.draw(self.heart.sprite, width/2, height/2, self.heart.rot, self.heart.scale, self.heart.scale, 43, 39)
  love.graphics.pop()
  
  love.graphics.push()
  love.graphics.setColor(1, 1, 1, self.alpha)
  love.graphics.setShader(self.textshader)
  love.graphics.draw(
    self.text.obj,
    (width  / 2) - (self.text.width   / 2),
    (height / 2) - (self.text.height  / 2) + (height / 10) + 62
  )
  love.graphics.pop()

  love.graphics.push()
  love.graphics.setShader(self.logoshader)
  love.graphics.draw(
    self.logo.sprite,
    (width  / 2) - (self.logo.width   / 4),
    (height / 2) + (self.logo.height  / 4) + (height / 10),
    0, 0.5, 0.5
  )
  love.graphics.setShader()
  love.graphics.pop()
  
  
  love.graphics.push()
  love.graphics.setColor(colors.pink)
  love.graphics.rectangle("fill", 0,0, width/2 * self.upstripes.scaleWidth, height )
  love.graphics.setColor(colors.blue)
  love.graphics.rectangle("fill",width, 0, -(width/2 * self.upstripes.scaleWidth), height )
  love.graphics.pop()
  
end

function splashlib:update(dt)
  timer.update(dt)
end

function splashlib:skip()
  if not self.done then
    self.done = true
    
    timer.script(function(wait)
    timer.clear()
    
    timer.tween(0.3, self, {alpha = 0}, "sine")
    timer.tween(0.3, self.heart, {scale = 0}, "sine")
    timer.tween(0.3, self.stripes, {scaleWidth = 0}, "sine")
    wait(1)
    timer.clear() -- to be safe
    if self.onDone then self.onDone() end
    end)
  end
end

setmetatable(splashlib, { __call = function(self, ...) return self.new(...) end })

return splashlib
