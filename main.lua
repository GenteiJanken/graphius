--[[
	Graphius - a shmup with a novel upgrade mechanic
	created by Josh Douglass-Molloy for a Pirate-Kart type thing
]]--
SCREEN_WIDTH = 600
SCREEN_HEIGHT = 600

DEFAULT_COLOUR = {255, 255, 255, 255} 
WINDOW_COLOUR = {65, 102, 255, 150}
NODE_COLOURS = {
	GREY = {50, 50, 50},
	RED = {255, 0, 0},
	BLUE = {0, 255, 0},
	GREEN = {0, 0, 255}	}




function love.load()
	--settings
	love.graphics.setCaption("Graphius")
	love.graphics.setMode(SCREEN_WIDTH, SCREEN_HEIGHT)
	game_state = "FLIGHT"
	--create star background
	stars:init()

	--initialise upgrade graph
	techgraph:init()

	--initialise entities
end


function love.update(dt)
	
	--if in-game, update
	if game_state == "FLIGHT" then
	--animate star background
	stars:update(dt)

	end
	
end


function love.draw()
	

	--draw star background
	stars:draw()

	--in GRAPH mode, draw graph
	if game_state == "GRAPH" then
		techgraph:draw()
	elseif game_state == "DRAG" then
	
	end
	
	
end

--mouse controls activated in GRAPH/DRAG state
function love.mousepressed(x, y, button)

	if game_state == "GRAPH" and button == "l" then
		techgraph:grab_shard(x, y)
		
	end
end

function love.mousereleased(x, y, button)

	if game_state == "DRAG" then
		
	end
end

--tab toggled FLIGHT/GRAPH, other keys only activated in FLIGHT
function love.keypressed(key)
	--toggles between graph view and flight view
	if key == 'tab' then
		game_state = game_state == "FLIGHT" and "GRAPH" or "FLIGHT"
	end
		
end



stars = {}

function stars:init()
	self.starmap = {}
	for i = 1, 3 do
		t = {}
		for j = 1, 20 do
			t2 = {
					x = math.random(SCREEN_WIDTH) - 1,
					y = math.random(SCREEN_HEIGHT) - 1
				}
			t[j] = t2
		end
		self.starmap[i] = t
	end
end

function stars:update(dt)
	for i = 1, 3 do
		for j = 1, 20 do
			self.starmap[i][j].y = (self.starmap[i][j].y + (4 - i) * 4) % SCREEN_HEIGHT 
		end
	end
end

function stars:draw()
	
	for i = 1, 3 do
		for j = 1, 20 do
			love.graphics.circle("fill", self.starmap[i][j].x, self.starmap[i][j].y, 0.5 * i)
		end
	end
end

techgraph = {}

function techgraph:draw()
	--draw pane
	love.graphics.setColor(unpack(WINDOW_COLOUR))
	love.graphics.rectangle("fill",0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
	
	--draw shards
	for i, v in ipairs(self.shards) do
		love.graphics.setColor(unpack(NODE_COLOURS[v]))
		love.graphics.rectangle("fill", self.shard_offset[1] * i, self.shard_offset[2], 20, 20)   
	end
	--draw graph
	--edges
		for _, v in ipairs(self.edges) do
			love.graphics.setLine(5, "smooth")
			love.graphics.setColor(unpack(DEFAULT_COLOUR))
			love.graphics.line(self.draw_points[v[1]][1], self.draw_points[v[1]][2], self.draw_points[v[2]][1], self.draw_points[v[2]][2])

		end	
	--nodes
		for k, v in pairs(self.draw_points) do 
			love.graphics.setColor(unpack(NODE_COLOURS[self.nodes[k]]))
			love.graphics.circle("fill", v[1], v[2], 10)		
		end	
		
	
	--reset colour
	love.graphics.setColor(unpack(DEFAULT_COLOUR))
end

function techgraph:init()
		
	self.shards = {"RED", "GREEN", "BLUE"}
	self.shard_offset = {25, 50}
	self.shard_drag = nil

	self.nodes = {A = "GREY",
					B = "GREY", 
					C = "GREY", 
					D = "GREY", 
					E = "GREY", 
					F = "GREY", 
					G = "GREY"}

	self.edges = {{"A", "B"}, {"A", "D"}, {"B", "C"}, {"C", "D"},
					{"B", "E"}, {"C", "F"}, {"D", "G"}, {"E", "F"},
					{"F", "G"}}
	self.draw_centre = {SCREEN_WIDTH/2, SCREEN_HEIGHT/2}
	self.draw_radius = 200
	self.draw_points = {}
	self.draw_points["C"] = {self.draw_centre[1], self.draw_centre[2]}
	self.draw_points["F"] = {self.draw_centre[1] + self.draw_radius/2 * math.cos(math.rad(270)), self.draw_centre[2] - self.draw_radius/2 * math.sin(math.rad(270))}

	
	self.draw_points["A"] = {self.draw_centre[1] + self.draw_radius * math.cos(math.rad(90)), self.draw_centre[2] - self.draw_radius * math.sin(math.rad(90))}
	self.draw_points["E"] = {self.draw_centre[1] + self.draw_radius * math.cos(math.rad(210)), self.draw_centre[2] - self.draw_radius * math.sin(math.rad(210))}
	self.draw_points["G"] = {self.draw_centre[1] + self.draw_radius * math.cos(math.rad(330)), self.draw_centre[2] - self.draw_radius * math.sin(math.rad(330))}
	mid = midpoint(self.draw_points["A"], self.draw_points["E"])
	self.draw_points["B"] = {mid[1], mid[2]}
	mid = midpoint(self.draw_points["A"], self.draw_points["G"])
	self.draw_points["D"] = {mid[1], mid[2]}
				
end

function techgraph:can_colour(node, colour)


	--get neighbours of node	
	neighbours = {}

	for _, v in ipairs(self.edges) do
		if v[1] == node then
			table.insert(neighbours, v[2])
		elseif v[2] == node then
			table.insert(neighbours, v[1])
		end
	end
	
	--if any neighbour already has supplied colour, reject 
	for _, v in ipairs(neighbours) do
		
		if self.nodes[v] == colour then
			return false
		end
	end
	
	--else accept
	return true

end

function techgraph:add_shard(colour)
	
	--if shard queue full, first make space
	if #self.shards == 10 then
		table.remove(self.shards, #self.shards)
	end
	table.insert(self.shards, colour, 1)
end

function techgraph:grab_shard(x, y)

end

function midpoint(p1, p2)
	return {(p1[1] + p2[1])/2, (p1[2]+p2[2])/2}
end


