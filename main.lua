local luaExt = require("lua-ext")
local mainMenuBar = require("main-menu-bar")
local titleFont = "fonts/Jost-500-Medium.ttf"
local subTitleFont = "fonts/Jost-400-Book.ttf"
local fontAwesomeBrandsFont = "fonts/FA5-Brands-Regular.ttf"

local applicationMainMenuBar =
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
						iconName = _G.isLinux and "" or "tools",
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
						iconName = _G.isLinux and "" or "turntable",
						useCheckmark = true,
						checkMarkIsOn = false,
						onClick = function(event)
						end
					},
					{
						title = "Fade Out Track",
						iconName = _G.isLinux and "" or "turntable",
						useCheckmark = true,
						checkMarkIsOn = false,
						onClick = function(event)
						end
					},
					{
						title = "Crossfade",
						iconName = _G.isLinux and "" or "music",
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
						iconName = _G.isLinux and "" or "palette",
						onClick = function(event)
						end
					},
					{
						title = "Dark Theme",
						iconName = _G.isLinux and "" or "palette",
						onClick = function(event)
						end
					},
					{
						title = "Hacker Theme",
						iconName = _G.isLinux and "" or "palette",
						onClick = function(event)
						end
					}
				}
			},
			{
				title = "Help",
				subItems = {
					{
						title = "Support Me On Patreon",
						iconName = _G.isLinux and "" or "patreon",
						font = fontAwesomeBrandsFont,
						onClick = function(event)
							system.openURL("https://www.patreon.com/dannyglover")
						end
					},
					{
						title = "Report Bug",
						iconName = _G.isLinux and "" or "github",
						font = fontAwesomeBrandsFont,
						onClick = function(event)
							system.openURL("https://github.com/DannyGlover/SDC")
						end
					},
					{
						title = "Submit Feature Request",
						iconName = _G.isLinux and "" or "trello",
						font = fontAwesomeBrandsFont,
						onClick = function(event)
							system.openURL("https://github.com/DannyGlover/SDC")
						end
					},
					{
						title = "Visit Website",
						iconName = _G.isLinux and "" or "browser",
						onClick = function(event)
							system.openURL("https://dannyglover.uk")
						end
					},
					{
						title = "About",
						iconName = _G.isLinux and "" or "info-circle",
						onClick = function(event)
						end
					}
				}
			}
		}
	}
)
