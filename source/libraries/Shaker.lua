-- Written by Dustin Mierau: https://devforum.play.date/t/shaker-a-class-for-shake-detection/1977

local STANDARD_GRAVITY <const> = 9.80665

Shaker = {}
Shaker.__index = Shaker

Shaker.kSensitivityLow = 10
Shaker.kSensitivityMedium = 14
Shaker.kSensitivityHigh = 20

function Shaker.new(callback, options)
	options = options or {}
	
	local shaker = {}
	setmetatable(shaker, Shaker)
	
	shaker.threshold = options.threshold or 0.5
	shaker.sensitivity = options.sensitivity or Shaker.kSensitivityMedium
	shaker.sample_size = options.samples or 20
	
	shaker.callback = callback
	shaker.enabled = false
	
	shaker:reset()
	
	return shaker
end

function Shaker:setEnabled(enable)
	self.enabled = enable
end

function Shaker:reset()
	if not self.shake_samples or #self.shake_samples > 0 then
		self.shake_samples = table.create(self.samples_window)
	end
	self.shake_sample_total = 0
end

function Shaker:update()
	if not self.enabled then
		return
	end
	
	if not playdate.accelerometerIsRunning() then
		self:reset()
		return
	end
	
	self:sample()
	
	-- Start testing for shakes once we have enough samples.
	if #self.shake_samples == self.sample_size then
		self:test()
	end
end

function Shaker:sample()
	local x, y, z = playdate.readAccelerometer()
	
	x *= STANDARD_GRAVITY
	y *= STANDARD_GRAVITY
	z *= STANDARD_GRAVITY
	
	local accel = x * x + y * y + z * z
	local accelerating = (accel > (self.sensitivity * self.sensitivity)) and 1 or 0
	
	if #self.shake_samples == self.sample_size then
		self.shake_sample_total -= self.shake_samples[1]
		table.remove(self.shake_samples, 1)
	end
	
	self.shake_samples[#self.shake_samples + 1] = accelerating
	self.shake_sample_total += accelerating
end

function Shaker:test()
	local average = self.shake_sample_total / #self.shake_samples
	if average > self.threshold then
		self:reset()
		self.callback()
	end
end