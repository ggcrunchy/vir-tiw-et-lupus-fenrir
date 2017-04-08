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
local composer = require("composer")
local widget = require("widget")

local Layer

widget.setTheme("widget_theme_android_holo_dark")

return utils.NewScene(
	-- Show --
	function(scene, event)
		Layer = display.newGroup()

		scene.view:insert(Layer)

		local names = { "Prudentia", "Fortitudo", "Iustitia", "Temperantia", "Ending" }
		local count = utils.GetLevelsBeaten() + 1
		local y = display.contentCenterY - (count / 2) * 90

		for i = 1, count do
			local b = widget.newButton{
				left = display.contentCenterX - 100,
				top = y,
				label = names[i],
				width = 200,
				height = 70,
				onRelease = function(event)
					composer.gotoScene("summary", { params = { index = i, name = names[i]:lower() } })
				end
			}

			Layer:insert(b)
			
			y = y + 100
		end
	end,

	-- Hide --
	function(scene)
		Layer:removeSelf()
	end
)