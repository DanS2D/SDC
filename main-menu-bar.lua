local M = {}
local theme = require("theme")
local buttonLib = require("button")
local switchLib = require("switch")
local desktopTableView = require("desktop-table-view")
local uPack = unpack
local fontAwesomeSolidFont = "fonts/FA5-Solid.ttf"
local fontAwesomeBrandsFont = "fonts/FA5-Brands-Regular.ttf"
local isDisabled = false
local menuBarHeight = 28
local rowHeight = menuBarHeight + 6

function M:new(options)
	local menuBarColor = options.menuBarColor or theme:get().backgroundColor.secondary
	local menuBarOverColor = options.menuBarOverColor or theme:get().backgroundColor.primary
	local font = options.font or native.systemFont
	local fontSize = options.fontSize or (menuBarHeight / 2)
	local itemWidth = options.itemWidth or 60
	local itemListWidth = options.itemListWidth or 250
	local items = options.items or error("options.items (table) expected, got %s", type(options.items))
	local rowColor = {default = theme:get().rowColor.primary, over = theme:get().rowColor.over}
	local parentGroup = options.parentGroup or display.currentStage
	local group = display.newGroup()
	local isItemOpen = false
	local menuButtons = {}
	local primaryTextColor = theme:get().textColor.primary
	local secondaryTextColor = theme:get().textColor.secondary

	local background = display.newRect(0, 0, display.contentWidth, menuBarHeight)
	background.anchorX = 0
	background.x = 0
	background.y = background.contentHeight * 0.5
	background:setFillColor(unpack(menuBarColor))
	background:addEventListener(
		"touch",
		function()
			group:close()
			native.setKeyboardFocus(nil)
			return true
		end
	)
	group:insert(background)

	local function closeSubmenus(excludingTarget)
		local target = excludingTarget or {index = 0}

		for j = 1, #menuButtons do
			if (j ~= target.index) then
				menuButtons[j]:setFillColor(primaryTextColor[1], primaryTextColor[2], primaryTextColor[3], primaryTextColor[4])
				menuButtons[j]:closeSubmenu()
			end
		end

		native.setKeyboardFocus(nil)
	end

	function group:close()
		isItemOpen = false
		closeSubmenus()
	end

	for i = 1, #items do
		local tableViewParams = {}

		local mainButton =
			buttonLib.new(
			{
				iconName = items[i].title,
				font = font,
				fontSize = fontSize + 4,
				fillColor = primaryTextColor,
				onClick = function(event)
					local target = event.target

					if (isDisabled) then
						return
					end

					isItemOpen = not isItemOpen

					if (not isItemOpen) then
						closeSubmenus()
					else
						target:setFillColor(secondaryTextColor[1], secondaryTextColor[2], secondaryTextColor[3], secondaryTextColor[4])
						target:openSubmenu()
						closeSubmenus(target)
					end
				end
			}
		)
		mainButton.anchorX = 0
		mainButton.x = i == 1 and 10 or menuButtons[i - 1].x + menuButtons[i - 1].contentWidth + 10
		mainButton.y = menuBarHeight * 0.5
		mainButton.index = i

		function mainButton:openSubmenu()
			self.mainTableView.isVisible = true
			self.mainTableView.outlineRect.isVisible = true
			self.mainTableView.outlineRect:toFront()
			self.mainTableView:toFront()

			display.getCurrentStage():insert(self.mainTableView)
		end

		function mainButton:closeSubmenu()
			self.mainTableView.isVisible = false
			self.mainTableView.outlineRect.isVisible = false
		end

		local height = #items[i].subItems * menuBarHeight
		menuButtons[i] = mainButton

		mainButton.mainTableView =
			desktopTableView.new(
			{
				left = i == 1 and 0 or menuButtons[i].x,
				top = menuBarHeight,
				width = itemListWidth,
				height = height,
				rowHeight = rowHeight,
				rowLimit = 0,
				rowColorDefault = rowColor,
				useSelectedRowHighlighting = false,
				onRowRender = function(event)
					local phase = event.phase
					local row = event.row
					local rowContentWidth = row.contentWidth
					local rowContentHeight = row.contentHeight
					local params = tableViewParams[row.index]
					local icon =
						display.newText(
						{
							x = 0,
							y = (rowContentHeight * 0.5),
							text = params.iconName,
							font = params.font,
							fontSize = fontSize,
							align = "left"
						}
					)
					icon.x = 8 + (icon.contentWidth * 0.5)
					icon:setFillColor(uPack(theme:get().iconColor.primary))
					row:insert(icon)

					local subItemText =
						display.newText(
						{
							x = 0,
							y = (rowContentHeight * 0.5),
							text = params.title,
							font = font,
							fontSize = fontSize + 2,
							align = "left"
						}
					)
					subItemText.anchorX = 0
					subItemText.x = 30
					subItemText:setFillColor(primaryTextColor[1], primaryTextColor[2], primaryTextColor[3], primaryTextColor[4])
					row:insert(subItemText)

					if (params.useCheckmark) then
						-- have to convert to boolean
						local isOn = toboolean(params.checkMarkIsOn)

						local switch =
							switchLib.new(
							{
								y = rowContentHeight * 0.5,
								offIconName = os.isLinux and "" or "square-full",
								onIconName = os.isLinux and "" or "check-square",
								fontSize = fontSize,
								parent = group,
								onClick = function(event)
								end
							}
						)
						switch.anchorX = 1
						switch.x = rowContentWidth - 14
						row.switch = switch

						switch:setIsOn(isOn)
						row:insert(switch)

						local switchUnderlay =
							display.newRect(rowContentWidth * 0.5, rowContentHeight * 0.5, rowContentWidth, rowContentHeight)
						switchUnderlay.fill = {0, 0, 0, 0.01}
						switchUnderlay:addEventListener(
							"touch",
							function(event)
								local phase = event.phase

								if (phase == "began") then
									switch:setIsOn(not switch:getIsOn())

									if (type(params.onClick) == "function") then
										event.isSwitch = true
										event.isOn = switch:getIsOn()
										params.onClick(event)
									end
								end

								return true
							end
						)

						row:insert(switchUnderlay)
					end
				end,
				onRowClick = function(event)
					local phase = event.phase
					local row = event.row
					local params = tableViewParams[row.index]

					if (isDisabled) then
						return
					end

					if (not params.useCheckmark) then
						isItemOpen = false
						closeSubmenus()
					end

					if (type(params.onClick) == "function") then
						params.onClick(event)
					end

					return true
				end
			}
		)
		mainButton.mainTableView:addEventListener(
			"tap",
			function()
				return true
			end
		)
		mainButton.mainTableView:addEventListener(
			"mouse",
			function(event)
				local eventType = event.type

				if (eventType == "move") then
					local x, y = event.target:contentToLocal(event.x, event.y)

					-- handle subItems (the tableview contents)
					for i = 1, event.target:getMaxRows() do
						local row = event.target:getRowAtIndex(i)
						local rowYStart = rowHeight * (i - 1)
						local rowYEnd = rowHeight * i

						if (y >= rowYStart and y <= rowYEnd) then
							row._background:setFillColor(uPack(rowColor.over))
						else
							row._background:setFillColor(uPack(rowColor.default))
						end
					end
				end

				return true
			end
		)
		mainButton.mainTableView.isVisible = false
		menuButtons[i] = mainButton

		mainButton.mainTableView.outlineRect =
			display.newRoundedRect(0, 0, itemListWidth + 2, (#items[i].subItems * rowHeight) + 2, 2)
		mainButton.mainTableView.outlineRect.strokeWidth = 1
		mainButton.mainTableView.outlineRect:setFillColor(uPack(theme:get().backgroundColor.primary))
		mainButton.mainTableView.outlineRect:setStrokeColor(uPack(theme:get().backgroundColor.outline))
		mainButton.mainTableView.outlineRect.x =
			mainButton.mainTableView.x + mainButton.mainTableView.contentWidth +
			mainButton.mainTableView.outlineRect.contentWidth * 0.5 -
			2
		mainButton.mainTableView.outlineRect.y =
			mainButton.mainTableView.y + mainButton.mainTableView.contentHeight +
			mainButton.mainTableView.outlineRect.contentHeight * 0.5 -
			2
		mainButton.mainTableView.outlineRect.isVisible = false

		for k = 1, #items[i].subItems do
			tableViewParams[#tableViewParams + 1] = {
				title = items[i].subItems[k].title,
				iconName = items[i].subItems[k].iconName,
				useCheckmark = items[i].subItems[k].useCheckmark,
				checkMarkIsOn = items[i].subItems[k].checkMarkIsOn,
				font = items[i].subItems[k].font or fontAwesomeSolidFont,
				onClick = items[i].subItems[k].onClick
			}
		end

		mainButton.mainTableView:setMaxRows(#tableViewParams)
		mainButton.mainTableView:createRows()

		group:insert(mainButton)
		group:insert(mainButton.mainTableView)
	end

	local overButton =
		display.newText(
		{
			text = "",
			font = font,
			fontSize = fontSize + 4
		}
	)
	overButton.anchorX = 0
	overButton.x = -500
	overButton.y = -500
	overButton:setFillColor(secondaryTextColor[1], secondaryTextColor[2], secondaryTextColor[3], secondaryTextColor[4])
	group:insert(overButton)

	local function onMouseEvent(event)
		local eventType = event.type

		if (isDisabled) then
			return
		end

		if (eventType == "move") then
			for i = 1, #menuButtons do
				local button = menuButtons[i]
				local buttonXStart = button.x
				local buttonXEnd = button.x + button.contentWidth
				local buttonYStart = 0
				local buttonYEnd = button.y + button.contentHeight * 0.5
				local x = event.x
				local y = event.y

				-- handle main menu buttons
				if (y >= buttonYStart and y <= buttonYEnd) then
					if (x >= buttonXStart and x <= buttonXEnd) then
						if (isItemOpen) then
							closeSubmenus(button)
							button:openSubmenu()

							if (overButton.text ~= button.text) then
								overButton.text = button.text
								overButton.x = button.x
								overButton.y = button.y
							end
						else
							if (overButton.text ~= button.text) then
								overButton.text = button.text
								overButton.x = button.x
								overButton.y = button.y
							end
						end
					end
				end
			end

			if
				(event.x > menuButtons[#menuButtons].x + menuButtons[#menuButtons].contentWidth or
					event.y > background.contentHeight - 2)
			 then
				overButton.x = -500
				overButton.y = -500
			end
		end
	end

	background:addEventListener("mouse", onMouseEvent)

	function group:onResize()
		background.width = display.contentWidth
	end

	parentGroup:insert(group)

	return group
end

function M:setEnabled(enabled)
	isDisabled = not enabled
end

function M:getHeight()
	return menuBarHeight
end

return M
