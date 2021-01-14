local luaExt = require("lua-ext")
local mainMenuBar = require("main-menu-bar")
local floatingPanel = require("floating-panel")
local titleFont = "fonts/Jost-500-Medium.ttf"
local subTitleFont = "fonts/Jost-400-Book.ttf"
local fontAwesomeBrandsFont = "fonts/FA5-Brands-Regular.ttf"
local applicationMainMenuBar = nil
local tilePanel = nil

math.randomseed(os.time())

-- create the main menu bar
applicationMainMenuBar =
	mainMenuBar:new(
	{
		font = titleFont,
		items = {
			{
				title = "File",
				subItems = {
					{
						title = "Add Music Folder",
						iconName = _G.isLinux and "" or "folder-plus",
						onClick = function()
						end
					},
					{
						title = "Add Music File(s)",
						iconName = _G.isLinux and "" or "file-music",
						onClick = function()
						end
					},
					{
						title = "Import Music Library",
						iconName = _G.isLinux and "" or "file-import",
						onClick = function()
						end
					},
					{
						title = "Export Music Library",
						iconName = _G.isLinux and "" or "file-export",
						onClick = function()
						end
					},
					{
						title = "Delete Music Library",
						iconName = _G.isLinux and "" or "trash",
						onClick = function()
						end
					},
					{
						title = "Exit",
						iconName = _G.isLinux and "" or "power-off",
						onClick = function()
							native.requestExit()
						end
					}
				}
			},
			{
				title = "Edit",
				subItems = {
					{
						title = "Preferences",
						iconName = os.isLinux and "" or "tools",
						onClick = function(event)
						end
					}
				}
			},
			{
				title = "Music",
				subItems = {
					{
						title = "Fade In Track",
						iconName = os.isLinux and "" or "turntable",
						useCheckmark = true,
						checkMarkIsOn = false,
						onClick = function(event)
						end
					},
					{
						title = "Fade Out Track",
						iconName = os.isLinux and "" or "turntable",
						useCheckmark = true,
						checkMarkIsOn = false,
						onClick = function(event)
						end
					},
					{
						title = "Crossfade",
						iconName = os.isLinux and "" or "music",
						useCheckmark = true,
						checkMarkIsOn = false,
						onClick = function(event)
						end
					}
				}
			},
			{
				title = "View",
				subItems = {
					{
						title = "Light Theme",
						iconName = os.isLinux and "" or "palette",
						onClick = function(event)
						end
					},
					{
						title = "Dark Theme",
						iconName = os.isLinux and "" or "palette",
						onClick = function(event)
						end
					},
					{
						title = "Hacker Theme",
						iconName = os.isLinux and "" or "palette",
						onClick = function(event)
						end
					},
					{
						title = "Show Tile Panel",
						iconName = os.isLinux and "" or "th-large",
						onClick = function(event)
							tilePanel:open(true)
						end
					}
				}
			},
			{
				title = "Help",
				subItems = {
					{
						title = "Support Me On Patreon",
						iconName = os.isLinux and "" or "patreon",
						font = fontAwesomeBrandsFont,
						onClick = function(event)
							system.openURL("https://www.patreon.com/dannyglover")
						end
					},
					{
						title = "Report Bug",
						iconName = os.isLinux and "" or "github",
						font = fontAwesomeBrandsFont,
						onClick = function(event)
							system.openURL("https://github.com/DannyGlover/SDC")
						end
					},
					{
						title = "Submit Feature Request",
						iconName = os.isLinux and "" or "trello",
						font = fontAwesomeBrandsFont,
						onClick = function(event)
							system.openURL("https://github.com/DannyGlover/SDC")
						end
					},
					{
						title = "Visit Website",
						iconName = os.isLinux and "" or "browser",
						onClick = function(event)
							system.openURL("https://dannyglover.uk")
						end
					},
					{
						title = "About",
						iconName = os.isLinux and "" or "info-circle",
						onClick = function(event)
						end
					}
				}
			}
		}
	}
)

-- create the tile panel
tilePanel = floatingPanel:new({
	width = (display.contentWidth * 0.4),
	height = (display.contentHeight * 0.5),
	title = "Tiles",
})
tilePanel.x = (display.contentWidth - (tilePanel.width * 0.5) - 5)
tilePanel.y = (display.contentHeight - (tilePanel.height * 0.5))

for i = 1, 11 do
	for j = 1, 10 do
		local colorR = (math.random(1, 255) / 255)
		local colorG = (math.random(1, 255) / 255)
		local colorB = (math.random(1, 255) / 255)

		local rect = display.newRect(0, 0, 20, 20)
		rect.x = (22 * i) - (tilePanel.width * 0.5) - 4
		rect.y = (22 * j) - (tilePanel.width * 0.5) + 4
		rect:setFillColor(colorR, colorG, colorB)
		tilePanel:insert(rect)
	end
end
