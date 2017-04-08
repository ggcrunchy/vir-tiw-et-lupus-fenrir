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

local Tiw, Fenrir

local Layer

local Collected

return utils.NewScene(
	-- Show --
	function(scene, event)
		Collected = 0
		Layer = display.newGroup()

		scene.view:insert(Layer)

		local w, h = display.contentWidth / 3, display.contentHeight / 3

		Fenrir = display.newImage(Layer, "FenrirP.png", display.contentCenterX, display.contentCenterY)
		Tiw = display.newImage(Layer, "TiwP.png", .5 * w, 2 * h)

		utils.AddBody(Fenrir, true)
		utils.AddBody(Tiw, true)

		local away
		local Wait

		local function ChargeOrReturn ()
			local x, y

			if away then
				x, y = display.contentCenterX, display.contentCenterY
			else
				local row, col

				repeat
					row, col = math.random(3), math.random(3)
				until row ~= 2 or col ~= 2

				x, y = (col - .5) * w, (row - .5) * h
			end

			away = not away

			transition.to(Fenrir, { x = x, y = y, onComplete = Wait })
		end

		function Wait ()
			timer.performWithDelay(1000, ChargeOrReturn)
		end

		Wait()

		local items = {
			"Cat'sF", .5, .5,
			"WBeard", 2.5, .5,
			"MRoot", .5, 2.5,
			"BearS", 1.5, 2.5,
			"BirdS", 2.5, 2.5,
			"FishB", 2.5, 1.5
		}

		for i = 1, #items, 3 do
			local item = display.newGroup()

			Layer:insert(item)

			local circle = display.newCircle(item, items[i + 1] * w, items[i + 2] * h, 10)

			circle:setFillColor(math.random(), math.random(), math.random())

			utils.AddBody(circle, 10)

			display.newText(item, items[i], circle.x, circle.y, native.systemFont, 15)
		end

		if system.getInfo("platform") == "android" and system.getInfo("environment") == "device" then
			local info, angle = {
				0, -1, "up",
				1, 0, "right",
				0, 1, "down",
				-1, 0, "left"
			}, 0

			for i = 1, #info, 3 do
				local button = display.newImage(Layer, "Arrow.png", (.25 + info[i] * .15) * w, (.9 + info[i + 1] * .15) * h)

				button:addEventListener("touch", utils.TouchFunc)

				button.rotation, angle = angle, angle + 90

				button.m_dir = info[i + 2]
			end
		end

		utils.EnterLevel(event.params, function(other)
			if other == Fenrir then
				utils.LeaveLevel(false)
			else
				timer.performWithDelay(1, function()
					other.isBodyActive = false
				end)

				other.parent.isVisible = false

				Collected = Collected + 1

				if Collected == 6 then
					utils.LeaveLevel(true)
				end
			end
		end, Tiw, function(diff)
			local dir = utils.GetDir()

			if dir == "left" then
				Tiw.x = Tiw.x - 250 * diff
			elseif dir == "right" then
				Tiw.x = Tiw.x + 250 * diff
			elseif dir == "up" then
				Tiw.y = Tiw.y - 250 * diff
			elseif dir == "down" then
				Tiw.y = Tiw.y + 250 * diff
			end
		end)
	end,

	-- Hide --
	function()
		Layer:removeSelf()
	end,

	-- Create --
	function(scene)

	end
)