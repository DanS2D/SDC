local M = {}
local theme = require("theme")
local uPack = unpack
local fontAwesomeSolidFont = "fonts/FA5-Solid.ttf"

function M.new(options)
	local x = options.x or 0
	local y = options.y or 0
	local offIconName =
		options.offIconName or error("switch.new() offIconName (string) expected, got %s", type(options.offIconName))
	local onIconName =
		options.onIconName or error("switch.new() onIconName (string) expected, got %s", type(options.onIconName))
	local offFont = options.offFont or fontAwesomeSolidFont
	local onFont = options.onFont or fontAwesomeSolidFont
	local offAlpha = options.offAlpha or 1
	local fontSize = options.fontSize or 14
	local fillColor = options.fillColor or theme:get().iconColor.primary
	local onClick = options.onClick
	local parent = options.parent or display.getCurrentStage()
	local group = display.newGroup()
	group.x = x
	group.y = y
	group.isOn = false

	local offButton =
		display.newText(
		{
			text = offIconName,
			font = offFont,
			fontSize = fontSize,
			align = "center"
		}
	)
	offButton.alpha = offAlpha
	offButton.ignoreAlpha = offAlpha ~= 1
	offButton.isOffButton = true
	offButton:setFillColor(unpack(fillColor))
	group:insert(offButton)

	local onButton =
		display.newText(
		{
			text = onIconName,
			font = onFont,
			fontSize = fontSize,
			align = "center"
		}
	)
	onButton.isOffButton = false
	onButton.ignoreAlpha = false
	onButton.isVisible = false
	onButton:setFillColor(unpack(fillColor))
	group:insert(onButton)

	local function touch(event)
		local phase = event.phase
		local target = event.target
		local targetHalfWidth = (target.contentWidth * 0.5)
		local targetHalfHeight = (target.contentHeight * 0.5)
		local eventX, eventY = target:contentToLocal(event.x, event.y)

		if (phase == "began") then
			display.getCurrentStage():setFocus(target)

			if (not target.ignoreAlpha) then
				target:setFillColor(uPack(theme:get().iconColor.highlighted))
			end
		elseif (phase == "ended" or phase == "cancelled") then
			if (not target.ignoreAlpha) then
				target:setFillColor(uPack(theme:get().iconColor.primary))
			end

			if (eventX + targetHalfWidth >= 0 and eventX + targetHalfWidth <= target.contentWidth) then
				if (eventY + targetHalfHeight >= 0 and eventY + targetHalfHeight <= target.contentHeight) then
					if (target.isOffButton) then
						target.isVisible = false
						onButton.isVisible = true
					else
						target.isVisible = false
						offButton.isVisible = true
					end

					if (type(onClick) == "function") then
						onClick(event)
					end
				end
			end

			display.getCurrentStage():setFocus(nil)
		end

		return true
	end

	function group:getIsOn()
		return self.isOn
	end

	function group:setIsOn(isOn)
		offButton.isVisible = not isOn
		onButton.isVisible = isOn
		group.isOn = isOn
	end

	offButton:addEventListener("touch", touch)
	onButton:addEventListener("touch", touch)
	parent:insert(group)

	return group
end

return M
