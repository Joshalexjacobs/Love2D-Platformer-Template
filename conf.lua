-- Configuration file conf.lua for main.lua

function love.conf(t)
	t.title = "Platformer Template" -- The title of the window the game is in (string)
	t.version = "0.9.1"         -- The LÖVE version this game was made for (string)
	t.window.width = 800
	t.window.height = 600

	-- For Windows debugging
	t.console = true
end
