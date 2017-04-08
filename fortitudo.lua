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

local Hand, Fortitude

local Layer

local Move

local Degrade

local Teeth

local function UpdateTeeth ()
	local dx = -7

	for _, tooth in ipairs(Teeth) do
		tooth.x = tooth.x + dx

		local rx = tooth.contentBounds.xMax

		if rx <= 0 then
			tooth.x = display.contentWidth + tooth.width / 2 - rx
		end
	end
end

return utils.NewScene(
	-- Show --
	function(scene, event)
		Layer = display.newGroup()

		scene.view:insert(Layer)

		Hand = display.newImage(Layer, "Hand.png", 0, display.contentCenterY)

		Hand.anchorX, Hand.x = 0, 0

		Fortitude = display.newCircle(Layer, 0, 0, 15)

		Fortitude:setFillColor(0, .7, .5)

		local MaxBravery = 50
		local Bravery = MaxBravery

		Fortitude.isVisible, Fortitude.isBodyActive = false, false

		utils.AddBody(Hand, true)
		utils.AddBody(Fortitude, 15)

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

		local function LaunchFortitude ()
			local y = math.random(250, display.contentHeight - 250)

			Fortitude.x, Fortitude.y = display.contentWidth + 20, y
			Fortitude.isBodyActive, Fortitude.isVisible = true, true

			if Move then
				transition.cancel(Move)
			end

			Move = transition.to(Fortitude, {
				x = -100, time = 1500,
				onComplete = function()
					Fortitude.isBodyActive, Fortitude.isVisible = false, false

					timer.performWithDelay(3000, LaunchFortitude)
				end
			})
		end

		local Width = 250
		local R = display.newRect(Layer, 0, 150, Width, 50)

		R:setFillColor(1, 0, 0)

		R.anchorX, R.x = 0, display.contentWidth - Width - 50

		display.newText(Layer, "Fortitude", R.x - 100, R.y, native.systemFont, 20)

		local function UpdateMeter (amount)
			amount = Bravery + amount

			Bravery = math.max(0, math.min(amount, MaxBravery))

			if amount <= 0 then
				utils.LeaveLevel(false)
			end

			if R.path then -- in case timer was still running
				R.path.width = math.ceil(Width * Bravery / MaxBravery)
			end
		end

		LaunchFortitude()

		Degrade = timer.performWithDelay(500, function()
			UpdateMeter(-1.75)
		end, 0)

		local function Touch (event)
			if event.phase == "began" then
				timer.cancel(event.target.cancel_me)

				event.target:removeSelf()
			end

			return true
		end

		timer.performWithDelay(5000, function()
			local x, y = math.random(50, display.contentCenterX - 50), math.random(50, display.contentCenterY - 50)
			local panic = display.newCircle(Layer, x, y, 20)

			panic:setFillColor(1, 0, 0)
			panic:addEventListener("touch", Touch)

			panic.cancel_me = timer.performWithDelay(2000, function()
				UpdateMeter(-15)

				local flood = display.newRect(display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight)

				flood:setFillColor(1, 0, 0)
				panic:removeSelf()

				transition.to(flood, { alpha = 0, onComplete = display.remove })
			end)

		end, Duration / 5)

		local gum1 = display.newRect(Layer, display.contentCenterX, 7, display.contentWidth, 15)
		local gum2= display.newRect(Layer, display.contentCenterX, display.contentHeight - 7, display.contentWidth, 15)

		gum1:setFillColor(.9, 0, 0)
		gum2:setFillColor(.9, 0, 0)

		local dw = display.contentWidth / 18

		Teeth = {}

		for i = 1, 20 do
			local tooth1 = display.newImage(Layer, "Tooth.png")
			local tooth2 = display.newImage(Layer, "Tooth.png")

			tooth1.x, tooth1.y = (i + .5) * dw, tooth1.height / 2
			tooth2.x, tooth2.y = (i + .5) * dw, display.contentHeight - tooth2.height / 2
			tooth2.rotation = 180

			Teeth[#Teeth + 1] = tooth1
			Teeth[#Teeth + 1] = tooth2
		end

		Runtime:addEventListener("enterFrame", UpdateTeeth)

		if system.getInfo("platform") == "android" and system.getInfo("environment") == "device" then
			local info, angle = {
				0, -1, "up",
				0, 1, "down"
			}, 0

			for i = 1, #info, 3 do
				local button = display.newImage(Layer, "Arrow.png", .1 * display.contentWidth, (.2 + info[i + 1] * .05) * display.contentHeight)

				button:addEventListener("touch", utils.TouchFunc)

				button.rotation, angle = angle, angle + 180

				button.m_dir = info[i + 2]
			end
		end

		utils.EnterLevel(event.params, function(_)
			UpdateMeter(20)

			if Move then
				transition.cancel(Move)
			end

			Fortitude.isVisible = false

			timer.performWithDelay(1, function()
				Fortitude.isBodyActive, Fortitude.x = false, display.contentWidth + 30

				timer.performWithDelay(5000, LaunchFortitude)
			end)
		end, Hand, function(diff)
			local dir = utils.GetDir()

			if dir == "up" then
				Hand.y = Hand.y - 350 * diff
			elseif dir == "down" then
				Hand.y = Hand.y + 350 * diff
			end
		end)
	end,

	-- Hide --
	function()
		Layer:removeSelf()

		timer.cancel(Degrade)

		if Move then
			transition.cancel(Move)
		end

		Runtime:removeEventListener("enterFrame", UpdateTeeth)
	end,

	-- Create --
	function(scene)

	end
)