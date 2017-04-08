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

local FenrirAndTiw

local Layer

local Throw

return utils.NewScene(
	-- Show --
	function(scene, event)
		Layer = display.newGroup()

		scene.view:insert(Layer)

		FenrirAndTiw = display.newImage(Layer, "FenrirTiwJ.png", display.contentCenterX, 0)

		FenrirAndTiw.y = display.contentHeight - FenrirAndTiw.height / 2

		local MaxWeave = 50
		local Weave = math.ceil(MaxWeave / 8)

		local Width = 250
		local R = display.newRect(Layer, 0, 150, Width, 50)

		R:setFillColor(0, 0, 1)

		R.anchorX, R.x = 0, display.contentWidth - Width - 50

		display.newText(Layer, "Weave", R.x - 100, R.y, native.systemFont, 20)

		local function UpdateWeave (amount)
			amount = Weave + amount

			Weave = math.max(0, math.min(amount, MaxWeave))

			if amount <= 0 or amount >= MaxWeave then
				utils.LeaveLevel(amount >= MaxWeave)
			end

			if R.path then -- in case timer was still running
				R.path.width = math.ceil(Width * Weave / MaxWeave)
			end
		end

		UpdateWeave(0)

		local function Touch (event)
			if event.phase == "began" then
				if event.target.cancel_me then
					transition.cancel(event.target.cancel_me)
				end

				if event.target.m_do then
					event.target:m_do()
				end

				event.target:removeSelf()
			end

			return true
		end

		local function ShowDwarf ()
			if Layer.parent then
				local x, y = math.random(50, display.contentWidth - 50), math.random(90, display.contentCenterY)
				local dwarf = display.newImage(Layer, "Dwarf.png", x, y)

				function dwarf:m_do ()
					if self.parent then
						local patch = display.newImage(Layer, "Patch.png", x, y)

						timer.performWithDelay(1500, ShowDwarf)

						transition.to(patch, {
							x = FenrirAndTiw.x, y = FenrirAndTiw.y,
							time = 1000,
							onComplete = function(p)
								if p.parent then
									UpdateWeave(4)

									p:removeSelf()
								end
							end
						})
					end
				end

				dwarf:addEventListener("touch", Touch)

				timer.performWithDelay(900, function()
					if dwarf.parent then
						dwarf:removeSelf()

						timer.performWithDelay(500, ShowDwarf)
					end
				end)
			end
		end

		local function LaunchShears ()
			local angle = (1.15 + math.random() * .7) * math.pi
			local c, s = math.cos(angle), math.sin(angle)
			local r = (display.contentCenterX + display.contentCenterY) * 1.414
			local shears = display.newImage(Layer, "Shears.png", display.contentCenterX + r * c, display.contentCenterY + r * s)

			shears:scale(2.5, 2.5)

			shears.cancel_me = transition.to(shears, {
				x = FenrirAndTiw.x, y = FenrirAndTiw.y, time = 4500,
				rotation = math.random(15) * 360,
				onComplete = function(s)
					if s.parent then
						UpdateWeave(-8)

						s:removeSelf()
					end
				end
			})
			shears:addEventListener("touch", Touch)
		end

		Throw = timer.performWithDelay(1200, LaunchShears, 0)

		LaunchShears()
		ShowDwarf()

		utils.EnterLevel(event.params)
	end,

	-- Hide --
	function()
		timer.cancel(Throw)

		Layer:removeSelf()
	end,

	-- Create --
	function(scene)

	end
)