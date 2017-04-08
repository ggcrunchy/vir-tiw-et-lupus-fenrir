--
-- Permission is hereby granted, free of charge, to any person obtaining
-- a copy of this software and associated documentation files (the
-- "Software"), to deal in the Software without restriction, including
-- without limitation the rights to use, copy, modify, merge, publish,
-- distribute, sublicense, and/or sell copies of the Software, and to
-- permit persons to whom the Software is furnished to do so, subject to
-- the following conditions:
--
-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
-- IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
-- CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
-- TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
-- SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--
-- [ MIT license: http://www.opensource.org/licenses/mit-license.php ]
--

local M = {}

local composer = require("composer")
local physics = require("physics")

function M.AddBody (object, radius)
	if radius == true then
		radius = (object.width + object.height) / 4
	end

	physics.addBody(object, { radius = radius, isSensor = true })
end

-- Which way are we trying to move?; which way were we moving? --
local Dir, Was

-- A second held direction, to change to if Dir is released (seems to smooth out key input) --
local ChangeTo

-- Begins input in a given direction
local function BeginDir (_, target)
	local dir = target.m_dir

	if not Dir then
		Dir, Was = dir, dir
	elseif Dir ~= dir and not ChangeTo then
		ChangeTo = dir
	else
		return false
	end

	return true
end

-- Ends input in a given direction
local function EndDir (_, target)
	local dir = target.m_dir

	if Dir == dir or ChangeTo == dir then
		if Dir == dir then
			Dir = ChangeTo
			Was = Dir or Was
		end

		ChangeTo = nil
	end
end

-- Key input passed through BeginDir / EndDir, pretending to be a button --
local PushDir = {}

-- Processes direction keys or similar input, by pretending to push GUI buttons
local function KeyEvent (event)
	local key = event.keyName

	-- Directional keys from D-pad or trackball: move in the corresponding direction.
	-- The trackball seems to produce the "down" phase followed immediately by "up",
	-- so we let the player coast along for a few frames unless interrupted.
	-- TODO: Secure a Play or at least a tester, try out the D-pad (add bindings)
	if key == "up" or key == "down" or key == "left" or key == "right" then
		PushDir.m_dir = key

		if event.phase == "up" then
			EndDir(nil, PushDir)
		elseif BeginDir(nil, PushDir) then
			--
		end

	-- Propagate other / unknown keys; otherwise, indicate that we consumed the input.
	else
		return false
	end

	return true
end

-- --
local LastTime

-- --
local UpdateKeys

--
local function Updater (event)
	local now = event.time
	local last = LastTime or now

	UpdateKeys((now - last) / 1000)

	LastTime = now
end

--
local CollisionFunc, Object

--
local function Collision (event)
	if event.phase == "began" then
		local obj1, obj2 = event.object1, event.object2

		if obj1 == Object then
			CollisionFunc(obj2)
		elseif obj2 == Object then
			CollisionFunc(obj1)
		end
	end
end

-- --
local CurrentLevel, MaxLevel

--
function M.EnterLevel (which, collision, object, update_keys)
	CurrentLevel = which

	if collision then
		Runtime:addEventListener("collision", Collision)

		CollisionFunc, Object = collision, object
	end

	if update_keys then
		UpdateKeys = update_keys

		Runtime:addEventListener("key", KeyEvent)
		Runtime:addEventListener("enterFrame", Updater)
	end
end

function M.GetDir ()
	return Dir
end

function M.GetLevelsBeaten ()
	return MaxLevel
end

--
function M.LeaveLevel (won)
	if won and CurrentLevel > MaxLevel then
		local file = io.open(system.pathForFile("Progress.sav", system.DocumentsDirectory), "wb")

		if file then
			MaxLevel = CurrentLevel

			file:write(MaxLevel)
			file:close()
		end
	end

	if UpdateKeys then
		Runtime:removeEventListener("key", KeyEvent)
		Runtime:removeEventListener("enterFrame", Updater)
	end

	if CollisionFunc then
		Runtime:removeEventListener("collision", Collision)

		CollisionFunc, Object = nil
	end

	Dir, Was = nil
	ChangeTo = nil

	composer.gotoScene("winlose", { params = won })
end

--
function M.NewScene(show, hide, create)
	local scene = composer.newScene()

	if create then
		scene.create = create

		scene:addEventListener("create")
	end

	function scene:show (event)
		if event.phase == "did" then
			show(scene, event)
		end
	end

	scene:addEventListener("show")

	function scene:hide (event)
		if event.phase == "did" then
			hide(scene, event)
		end
	end

	scene:addEventListener("hide")

	return scene
end

-- Helper to attach begin-end input to buttons --
function M.TouchFunc (event)
	local phase, target = event.phase, event.target

	if phase == "began" then
		target.m_touched = true

		display.getCurrentStage():setFocus(event.target, event.id)

		BeginDir(nil, target)
	elseif target.m_touched and (phase == "ended" or phase == "cancelled") then
		target.m_touched = nil

		EndDir(nil, target)

		display.getCurrentStage():setFocus(event.target, nil)
	end

	return true
end

-- Startup
local file = io.open(system.pathForFile("Progress.sav", system.DocumentsDirectory), "rb")
local n

if file then
	n = tonumber(file:read("*n"))

	file:close()
end

MaxLevel = n or 0

physics.start()
physics.setGravity(0, 0)
--physics.setDrawMode("hybrid")

return M