local M = {}
local dWidth = display.contentWidth
local dHeight = display.contentHeight
local dRemove = display.remove
local tRemove = table.remove
local mMin = math.min
local mMax = math.max
local mModf = math.modf
local lType = type
local selectedRowIndex = 0
local dispatchedRowClickEvent = false

function M.new(options)
	local x = options.left or 0
	local y = options.top or 0
	local width = options.width or display.contentWidth
	local height = options.height or error("desktop-table-view() options.height number expect, got ", type(options.height))
	local maxRows = options.maxRows or 22
	local visibleRows = maxRows - 1
	local useMouseListener = options.useMouseListener
	local rowLimit = options.rowLimit or maxRows
	local rowColorDefault = options.rowColorDefault or {default = {0, 0, 0}, over = {0.2, 0.2, 0.2}}
	local rowHeight = options.rowHeight or 20
	local useSelectedRowHighlighting = options.useSelectedRowHighlighting
	local onRowRender =
		options.onRowRender or
		error("desktop-table-view() options.onRowRender function expected, got ", type(options.onRowRender))
	local onRowClick = options.onRowClick
	local onRowMouseClick = options.onRowMouseClick
	local onRowScroll = options.onRowScroll
	local rows = {}
	local lastMouseScrollWasUp = false
	local didMouseScroll = false
	local lockScrolling = false
	local realRowIndex = 0
	local realHeight = (display.contentHeight - y)
	local realRowVisibleCount, _ = mModf(realHeight / rowHeight)
	local tableView = display.newGroup() --display.newContainer(width, height)
	maxRows = realRowVisibleCount + 1
	visibleRows = maxRows - 1
	tableView.x = x
	tableView.y = y

	if (options.maxRows) then
		maxRows = options.maxRows
		visibleRows = maxRows - 1
	end

	--print("is row count even ", isRowCountEven)
	--print("we should be able to fit " .. realRowVisibleCount .. " rows on screen")

	local function onRowTap(event)
		local target = event.target
		local numClicks = event.numTaps
		rows[target.realIndex].isSelected = true

		local rowEvent = {
			row = target,
			numClicks = numClicks
		}

		onRowClick(rowEvent)
	end

	local function onRowMouse(event)
		local phase = event.type
		local target = event.target

		if (phase == "down") then
			if (event.isSecondaryButtonDown or event.isMiddleButtonDown) then
				if (type(onRowMouseClick) == "function") then
					local rowEvent = {
						row = target,
						isSecondaryButton = event.isSecondaryButtonDown,
						isMiddleButton = event.isMiddleButtonDown
					}

					onRowMouseClick(rowEvent)
				end
			end
		end

		return true
	end

	function tableView:createRows(params)
		local color = rowColorDefault.default

		if not (options.rowLimit) then
			realHeight = (display.contentHeight - y)
			realRowVisibleCount, _ = mModf(realHeight / rowHeight)
			maxRows = realRowVisibleCount + 1
			visibleRows = maxRows - 1
		end

		realRowIndex = maxRows

		for i = 1, maxRows do
			rows[i] = display.newGroup()

			rows[i]._background = display.newRect(0, 0, width, rowHeight)
			rows[i]._background.anchorX = 0
			rows[i]._background.x = 0
			rows[i]._background.y = (rowHeight * 0.5)
			rows[i]._background:setFillColor(unpack(color))
			rows[i]._background._isBackground = true
			rows[i]:insert(rows[i]._background)

			rows[i].y = i == 1 and 0 or rows[i - 1].y + rowHeight
			rows[i].index = i
			rows[i].realIndex = i
			rows[i].isSelected = false
			rows[i].contentWidth = width
			rows[i].contentHeight = rowHeight
			rows[i].isHitTestable = true
			rows[i]:addEventListener("tap", onRowTap)

			self:insert(rows[i])
			self:dispatchRowEvent(i)
		end
	end

	function tableView:didMouseScroll()
		return didMouseScroll
	end

	function tableView:deleteAllRows()
		if (#rows > 0) then
			for i = 1, maxRows do
				rows[i]:removeEventListener("tap", onRowTap)
				self:deleteRowContents(i)
				display.remove(rows[i])
				rows[i] = nil
			end

			rows = nil
			rows = {}
		end
	end

	function tableView:deleteRowContents(index)
		for i = rows[index].numChildren, 1, -1 do
			if (rows[index][i] and not rows[index][i]._isBackground) then
				display.remove(rows[index][i])
				rows[index][i] = nil
			end
		end
	end

	function tableView:destroy()
		selectedRowIndex = 0
		self:deleteAllRows()
		Runtime:removeEventListener("mouse", self)
		display.remove(self)
		self = nil
	end

	function tableView:dispatchRowEvent(rowIndex)
		local event = {
			row = rows[rowIndex],
			width = width,
			height = rowHeight,
			parent = self
		}

		onRowRender(event)
	end

	function tableView:getMaxRows()
		return maxRows
	end

	function tableView:getRealIndex()
		return realRowIndex
	end

	function tableView:getVisibleRows()
		return visibleRows
	end

	function tableView:getRowAtIndex(index)
		return rows[index]
	end

	function tableView:getRowRealIndex(index)
		for i = 1, maxRows do
			if (rows[i].index == index) then
				return rows[i].realIndex
			end
		end

		return 0
	end

	function tableView:getRowAtClickPosition(event)
		local eventX, eventY = self:contentToLocal(event.x, event.y)

		if (#rows > 0) then
			for i = 1, maxRows do
				if (eventY >= rows[i].y and eventY <= rows[i].y + rowHeight) then
					return rows[i]
				end
			end
		end
	end

	function tableView:getScrollDirection()
		return lastMouseScrollWasUp and "up" or "down"
	end

	function tableView:isRowOnScreen(index)
		local row = rows[index]
		local onScreen = false

		if (row.y + (rowHeight * 0.5) > 0 and row.y - (rowHeight * 0.5) < (rowHeight * visibleRows)) then
			onScreen = true
		end

		return onScreen
	end

	function tableView:lockScroll(lock)
		lockScrolling = lock
	end

	function tableView:moveRow(index, position)
		rows[index].y = position
	end

	--- When scrolling UP on the scrollwheel
	function tableView:moveAllRowsDown()
		for i = 1, maxRows do
			self:moveRow(i, rows[i].y + rowHeight)

			if (not self:isRowOnScreen(i)) then
				self:deleteRowContents(i)
				self:moveRow(i, 0)
				rows[i].index = realRowIndex > visibleRows and realRowIndex - visibleRows or i
				self:dispatchRowEvent(i)
			end
		end
	end

	--- When scrolling DOWN on the scrollwheel
	function tableView:moveAllRowsUp()
		for i = 1, maxRows do
			self:moveRow(i, rows[i].y - rowHeight)

			if (not self:isRowOnScreen(i)) then
				self:deleteRowContents(i)
				self:moveRow(i, visibleRows * rowHeight)
				rows[i].index = realRowIndex > visibleRows and realRowIndex or i
				self:dispatchRowEvent(i)
			end
		end
	end

	function tableView:reloadData()
		for i = 1, maxRows do
			self:deleteRowContents(i)
			self:dispatchRowEvent(i)
		end
	end

	function tableView:reloadRow(index)
		self:deleteRowContents(index)
		self:dispatchRowEvent(index)
	end

	function tableView:resizeAllRowBackgrounds(newWidth)
		for i = 1, maxRows do
			rows[i]._background.width = newWidth
		end
	end

	function tableView:setMaxRows(max)
		maxRows = max
	end

	function tableView:scrollToIndex(index)
		for i = 1, maxRows do
			if (index <= maxRows) then
				rows[i].index = i
			elseif (index >= rowLimit) then
				rows[i].index = mMin(rowLimit, (rowLimit - maxRows) + i)
			else
				rows[i].index = mMin(rowLimit, (index - maxRows) + i)
			end

			self:moveRow(i, rowHeight * (i - 1))
			self:deleteRowContents(i)
			self:dispatchRowEvent(i)
		end

		realRowIndex = rows[maxRows].index
	end

	function tableView:scrollToTop()
		self:scrollToIndex(1)
	end

	function tableView:scrollToBottom()
		self:scrollToIndex(rowLimit)
	end

	function tableView:setRowLimit(limit)
		rowLimit = limit + 1
	end

	function tableView:setRowSelected(rowIndex, viaScroll)
		if (not useSelectedRowHighlighting or not rows or #rows <= 0) then
			return
		end

		local defaultRowColor = rowColorDefault.default
		local overRowColor = rowColorDefault.over

		if (not viaScroll) then
			selectedRowIndex = rowIndex
		end

		if (selectedRowIndex >= 0) then
			for i = 1, maxRows do
				if (rows[i]) then
					if (rows[i].index == selectedRowIndex) then
						-- set the selected row to its over color
						if (rows[i]._background.fill.r < defaultRowColor[1]) then
							rows[i]._background:setFillColor(unpack(overRowColor))
						end
					else
						-- reset other rows to their default color
						if (rows[i]._background.fill.r > defaultRowColor[1]) then
							rows[i]._background:setFillColor(unpack(defaultRowColor))
						end
					end
				end
			end
		end
	end

	function tableView:mouse(event)
		local eventType = event.type
		local scrollY = event.scrollY

		if (eventType == "scroll") then
			-- TODO: get time between scroll events. if they are rapid, scroll faster
			lastMouseScrollWasUp = scrollY < 0
			didMouseScroll = true

			if (not lockScrolling) then
				if (lastMouseScrollWasUp) then
					realRowIndex = realRowIndex - 1

					if (realRowIndex >= maxRows) then
						tableView:moveAllRowsDown()
					else
						realRowIndex = maxRows
					end
				else
					realRowIndex = realRowIndex + 1

					if (realRowIndex <= rowLimit) then
						tableView:moveAllRowsUp()
					else
						realRowIndex = rowLimit
					end
				end
			end

			if (lType(onRowScroll) == "function") then
				onRowScroll()
			end
		else
			didMouseScroll = false
		end

		if (eventType == "down" and not dispatchedRowClickEvent) then
			if (event.isSecondaryButtonDown or event.isMiddleButtonDown) then
				if (type(onRowMouseClick) == "function") then
					local rowEvent = {
						row = self:getRowAtClickPosition(event),
						isSecondaryButton = event.isSecondaryButtonDown,
						isMiddleButton = event.isMiddleButtonDown,
						x = event.x,
						y = event.y
					}

					if (rowEvent.row) then
						onRowMouseClick(rowEvent)
						dispatchedRowClickEvent = true
					end
				end
			end
		elseif (eventType == "up") then
			dispatchedRowClickEvent = false
		end

		return true
	end

	if (useMouseListener) then
		Runtime:addEventListener("mouse", tableView)
	end

	return tableView
end

return M
