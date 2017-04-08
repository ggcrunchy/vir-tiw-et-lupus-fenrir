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
local text = require("text")
local composer = require("composer")
local widget = require("widget")

local Text

local Back, Go

local Level, Name

return utils.NewScene(
	-- Show --
	function(scene, event)
		local params = event.params

		Level, Name = params.index, params.name
		Text.text = text[Level]
		Go.isVisible = Level < 5
	end,

	-- Hide --
	function()
		--
	end,

	-- Create --
	function(scene)
		Text = display.newText(scene.view, "", display.contentCenterX, display.contentCenterY, native.systemFontBold, 15)
		
		Back = widget.newButton{
			left = 50,
			top = 50,
			label = "Back",
			width = 100,
			height = 70,
			onRelease = function()
				composer.gotoScene("title")
			end
		}

		Go = widget.newButton{
			left = 200,
			top = 50,
			label = "Go",
			width = 200,
			height = 70,
			onRelease = function()
				composer.gotoScene(Name, { params = Level })
			end
		}

		scene.view:insert(Back)
		scene.view:insert(Go)
	end
)