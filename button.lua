local M = {}
local theme = require("theme")
local uPack = unpack
local fontAwesomeSolidFont = "fonts/FA5-Solid.ttf"

function M.new(options)
	local x = options.x or 0
	local y = options.y or 0
	local iconName = options.iconName or error("button.new() iconName (string) expected, got %s", type(options.iconName))
	local fontSize = options.fontSize or 14
	local font = options.font or fontAwesomeSolidFont
	local onClick = options.onClick
	local parent = options.parent or display.getCurrentStage()

	local button =
		display.newText(
		{
			text = iconName,
			font = font,
			fontSize = fontSize,
			align = "center"
		}
	)
	button.x = x
	button.y = y
	button:setFillColor(uPack(theme:get().iconColor.primary))
	parent:insert(button)

	function button:touch(event)
		local phase = event.phase
		local target = event.target
		local targetHalfWidth = (target.contentWidth * 0.5)
		local targetHalfHeight = (target.contentHeight * 0.5)
		local eventX, eventY = target:contentToLocal(event.x, event.y)

		if (phase == "began") then
			display.getCurrentStage():setFocus(target)
			target:setFillColor(uPack(theme:get().iconColor.highlighted))
		elseif (phase == "ended" or phase == "cancelled") then
			target:setFillColor(uPack(theme:get().iconColor.primary))

			if (eventX + targetHalfWidth >= 0 and eventX + targetHalfWidth <= target.contentWidth) then
				if (eventY + targetHalfHeight >= 0 and eventY + targetHalfHeight <= target.contentHeight) then
					if (type(onClick) == "function") then
						onClick(event)
					end
				end
			end

			display.getCurrentStage():setFocus(nil)
		end

		return true
	end

	button:addEventListener("touch")

	return button
end

return M
