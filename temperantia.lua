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

local utils = require("utils")

local Tiw

local Layer

local Bleed, Throw

return utils.NewScene(
	-- Show --
	function(scene, event)
		Layer = display.newGroup()

		scene.view:insert(Layer)

		Tiw = display.newImage(Layer, "TiwT.png", display.contentCenterX, 0)

		Tiw.y = display.contentHeight - Tiw.height / 2

		local MaxSobriety = 50
		local Sobriety = MaxSobriety

		local Duration = 30

		local Clock = display.newText(Layer, Duration, display.contentCenterX, 100, native.systemFontBold, 30)

		Clock:setFillColor(1, 0, 0)

		timer.performWithDelay(1000, function()
			Duration = Duration - 1

			Clock.text = Duration

			if Duration == 0 then
				utils.LeaveLevel(true)
			end
		end, Duration)

		local Width = 250
		local R = display.newRect(Layer, 0, 150, Width, 50)

		R:setFillColor(1, 0, 0)

		R.anchorX, R.x = 0, display.contentWidth - Width - 50

		display.newText(Layer, "Temperance", R.x - 100, R.y, native.systemFont, 20)

		local function UpdateMeter (amount)
			amount = Sobriety + amount

			Sobriety = math.max(0, amount)

			if amount <= 0 then
				utils.LeaveLevel(false)
			end

			if R.path then -- in case timer was still running
				R.path.width = math.ceil(Width * Sobriety / MaxSobriety)
			end
		end

		local function Touch (event)
			if event.phase == "began" then
				transition.cancel(event.target.cancel_me)

				event.target:removeSelf()
			end

			return true
		end

		local function LaunchBottle ()
			local angle = (1.15 + math.random() * .7) * math.pi
			local c, s = math.cos(angle), math.sin(angle)
			local r = (display.contentCenterX + display.contentCenterY) * 2 * 1.414
			local bottle = display.newImage(Layer, "Drink.png", display.contentCenterX + r * c, display.contentCenterY + r * s)

			bottle:scale(2.5, 2.5)

			bottle.cancel_me = transition.to(bottle, {
				x = Tiw.x, y = Tiw.y, time = 6500,
				rotation = math.random(15) * 360,
				onComplete = function(b)
					UpdateMeter(-8)

					if b.parent then
						b:removeSelf()
					end
				end
			})
			bottle:addEventListener("touch", Touch)
		end

		Throw = timer.performWithDelay(1500, LaunchBottle, Duration / 1.5)

		LaunchBottle()

		local blood = {}

		for i = 1, 30 do
			local x, y = Tiw.x - 35, Tiw.y - 15
			local drop = display.newCircle(Layer, x + math.random(-11, 11), y + math.random(-11, 11), math.random(2, 4))

			drop:setFillColor(1, 0, 0)

			drop.isVisible = false

			blood[#blood + 1] = drop
		end

		Bleed = timer.performWithDelay(45, function()
			for i = 1, math.random(1, 6) do
				local drop = blood[math.random(#blood)]

				drop.isVisible = not drop.isVisible
			end
		end, 0)

		utils.EnterLevel(event.params)
	end,

	-- Hide --
	function()
		timer.cancel(Bleed)
		timer.cancel(Throw)

		Layer:removeSelf()
	end,

	-- Create --
	function(scene)

	end
)