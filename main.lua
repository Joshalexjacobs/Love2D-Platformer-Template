-- main.lua
--[[DEBUG SETTINGS]]
DEBUG = true

--[[BUMP INIT]]
-- require bump.lua
local math = require "math"
local bump = require 'bump'
local world = bump.newWorld() -- create a world with bump

--[[PLAYER AND PLAYER FUNCTIONS]]
-- our player rectangle
player = {x = 375, y = 250, w = 50, h = 50, dx = 0, dy = 0, speed = 150, initVel = 6, termVel = -3, isJumping = false, isGrounded = false}
jumpTimerMax = 0.4
jumpTimer = jumpTimerMax

-- UPDATE PLAYER MOVEMENT [http://2dengine.com/doc/gs_platformers.html]
local function updatePlayer(dt)
  local gravity, damping, maxVel = 9.8, 0.5, 6.0

  if love.keyboard.isDown('right') then
    player.dx = player.speed * dt
  elseif love.keyboard.isDown('left') then
    player.dx = -player.speed * dt
  end

  local decel = 5

  if love.keyboard.isDown("right") == false and player.dx > 0 then
		player.dx = math.max((player.dx - decel * dt), 0)
	elseif love.keyboard.isDown("left") == false and player.dx < 0 then
		player.dx = math.min((player.dx + decel * dt), 0)
  end

  -- this block locks in our velocity to maxVel
  local v = math.sqrt(player.dx^2 + player.dy^2)
  if v > maxVel then
    local vs = maxVel/v
    player.dx = player.dx*vs
    player.dy = player.dy*vs
  end

  -- these 2 lines handle damping (aka friction)
  player.dx = player.dx / (1 + damping * dt)
  player.dy = player.dy / (1 + damping * dt)

  jumpTimer = jumpTimer - (1 * dt) -- decrement jumpTimer

  if love.keyboard.isDown(' ') and not player.isJumping and player.isGrounded then -- when the player hits jump
    player.isJumping = true
    player.isGrounded = false
    player.dy = -player.initVel -- 6 is our initial velocity -- this is a temporary solution, will add initialvelocity later
    jumpTimer = jumpTimerMax
  elseif love.keyboard.isDown(' ') and jumpTimer > 0 and player.isJumping then
    player.dy = player.dy + (-0.5)
  elseif not love.keyboard.isDown(' ') and player.isJumping then -- if the player releases the jump button mid-jump...
    if player.dy < player.termVel then -- and if the player's velocity has reached the minimum velocity (minimum jump height)...
      player.dy = player.termVel -- terminate the jump
    end
    player.isJumping = false
  end

  -- constant force of gravity
  player.dy = player.dy + (gravity * dt)

  if DEBUG then
    print(player.dy)
  end

  if player.dx ~= 0 or player.dy ~= 0 then
    local cols
    player.x, player.y, cols, len = world:move(player, player.x + player.dx, player.y + player.dy)
    if len > 0 and not player.isJumping then -- check if the play is colliding with the ground
      player.isGrounded = true
    else
      player.isGrounded = false
    end
  end
end

-- [[BLOCK FUNCTIONS]]
local blocks = {}

local function addBlock(x,y,w,h)
  local block = {x=x,y=y,w=w,h=h}
  blocks[#blocks+1] = block
  world:add(block, x,y,w,h)
end

local function drawBlocks()
  for _,block in ipairs(blocks) do
    love.graphics.rectangle("fill", block.x, block.y, block.w, block.h)
  end
end

--[[LOVE LOAD]]
function love.load(arg)
  world:add(player, player.x, player.y, player.w, player.h)

  addBlock(love.graphics.getWidth()/2 - 160, love.graphics.getHeight()/2, 320, 60)
  addBlock(0, love.graphics.getHeight() - 25, 800, 160)
end

--[[LOVE UPDATE]]
function love.update(dt)
  updatePlayer(dt)
end

--[[LOVE DRAW]]
function love.draw()
  drawBlocks()
  love.graphics.rectangle("fill", player.x, player.y, player.w, player.h)
  if DEBUG then
    love.graphics.print("Platformer Template", 0, 0)
    love.graphics.print("X: " .. tostring(player.x), 0, 15)
    love.graphics.print("Y: " .. tostring(player.y), 0, 30)
  end
end
