local splashes = {
  ["simple-o-ten-one"]  = {module="simple-o-ten-one"}
}

local current, splash

local function next_splash()
  current = next(splashes, current) or next(splashes)
  splash = splashes[current]()
  splash.onDone = next_splash
end

function love.load()
  for name, entry in pairs(splashes) do
    entry.module = require(entry.module)
    splashes[name] = function ()
      return entry.module(unpack(entry))
    end
  end

  next_splash()
end

function love.update(dt)
  splash:update(dt)
end

function love.draw()
  splash:draw()
end

function love.keypressed(key)
  if key == "escape" then
    love.event.push("quit")
  end

  splash:skip()
end
