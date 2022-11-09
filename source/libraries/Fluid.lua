-- Written by Dustin Mierau: https://devforum.play.date/t/a-list-of-helpful-libraries-and-code/221/13

import "CoreLibs/graphics"

local graphics = playdate.graphics
local geometry = playdate.geometry

local function round(num)
	return num + 0.5 - (num + 0.5) % 1
end

local function clamp(val, min, max)
	return val < min and min or val > max and max or val
end

Fluid = {}
Fluid.__index = Fluid

function Fluid.new(x, y, width, height, options)
	options = options or {}
	
	local fluid = {}
	setmetatable(fluid, Fluid)
	
	-- Set default options.
	fluid.tension = options.tension or 0.03 -- Wave stiffness.
	fluid.dampening = options.dampening or 0.0025 -- Wave oscillation.
	fluid.speed = options.speed or 0.06 -- Wave speed.
	fluid.vertex_count = options.vertices or 20
	
	-- Allocate vertices.
	fluid.vertices = table.create(fluid.vertex_count, 0)
	
	-- Allocate polygon.
	fluid.polygon = geometry.polygon.new(fluid.vertex_count + 2)
	fluid.polygon:close()
	
	-- Set bounds.
	fluid:setBounds(x, y, width, height)
	
	-- Initialize.
	fluid:reset()
	
	return fluid
end

function Fluid:setBounds(x, y, width, height)
	self.bounds = geometry.rect.new(x, y, width, height)
	
	-- Update fluid column width.
	self.column_width = width / (self.vertex_count - 1)
	
	-- Update height of vertices.
	local b = false
	for _, v in ipairs(self.vertices) do
		local height_delta <const> = v.height - v.natural_height
		v.natural_height = height
		v.height = height + height_delta
	end
	
	-- Set bottom right and left vertices.
	local fluid_bottom <const> = self.bounds.y + self.bounds.height
	self.polygon:setPointAt(self.vertex_count + 1, self.bounds.x + self.bounds.width, fluid_bottom)
	self.polygon:setPointAt(self.vertex_count + 2, self.bounds.x, fluid_bottom)
end

function Fluid:reset()
	-- Reset vertices to 0.
	for i = 1, self.vertex_count do
		self.vertices[i] = {
			height = self.bounds.height,
			natural_height = self.bounds.height,
			velocity = 0
		}
	end
end

function Fluid:getPointOnSurface(x)
	x = clamp(x - self.bounds.x, 0, self.bounds.width)
	return self.polygon:pointOnPolygon(x)
end

function Fluid:touch(x, velocity)
	-- Don't allow touches outside the bounds of the water surface.
	if x < self.bounds.x or x > self.bounds.x + self.bounds.width then
		return
	end
	
	-- Apply velocity to vertex at touch point.
	local vertex_index <const> = clamp(round((((x - self.bounds.x) / self.bounds.width) * (self.vertex_count - 1)) + 1), 1, self.vertex_count)
	self.vertices[vertex_index].velocity = -velocity
end

function Fluid:update()
	-- Simulate springs on each vertex.
	for _, v in ipairs(self.vertices) do
		v.velocity += self.tension * (v.natural_height - v.height) - v.velocity * self.dampening
		v.height += v.velocity
	end
	
	-- Propagate changes to the left and right to create a waves.

	-- Propagate to the left.
	for i = self.vertex_count, 1, -1 do
		local vertex <const> = self.vertices[i]
		if i > 1 then
			local left_vertex <const> = self.vertices[i - 1]
			local left_change <const> = self.speed * (vertex.height - left_vertex.height)
			left_vertex.velocity += left_change
			left_vertex.height += left_change
		end
	end
		
	-- Propagate to the right
	for i, vertex in ipairs(self.vertices) do
		if i < self.vertex_count then
			local right_vertex <const> = self.vertices[i + 1]
			local right_change <const> = self.speed * (vertex.height - right_vertex.height)
			right_vertex.velocity += right_change
			right_vertex.height += right_change
		end
		
		-- Update corresponding vertex on polygon.
		self.polygon:setPointAt(
			i, 
			self.bounds.x + ((i-1) * self.column_width), 
			(self.bounds.y + self.bounds.height) - vertex.height
		)
	end
end

function Fluid:fill()
	graphics.fillPolygon(self.polygon)
end

function Fluid:draw()
	graphics.drawPolygon(self.polygon)
end