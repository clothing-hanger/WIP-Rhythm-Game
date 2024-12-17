local Splash = Class:extend()

function Splash:new(x,y)
    -- Assuming 'ellipse' is the texture you want to use for the particle
    self.particleSystem = love.graphics.newParticleSystem(Skin.Particles["Combo Alert"], 41)   -- made with hot particles, translated to my particle format thingy by chatgpt lmfao
    
    -- Setting up default particle properties
    self.particleSystem:setColors(1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0.5)
    self.particleSystem:setDirection(3.1416)
    self.particleSystem:setEmissionArea("borderrectangle", 59.28, 12.78, 0, false)
    self.particleSystem:setEmissionRate(0)
    self.particleSystem:setEmitterLifetime(-1)
    self.particleSystem:setInsertMode("top")
    self.particleSystem:setLinearDamping(0.81, 0.45)
    self.particleSystem:setOffset(49.1, 10.5)
    self.particleSystem:setParticleLifetime(0.5,0.7)
    self.particleSystem:setSizes(0.1705)
    self.particleSystem:setSizeVariation(1)
    self.particleSystem:setSpeed(500,600)
    self.particleSystem:setSpread(0.3291)
    self.particleSystem:setTangentialAcceleration(-0.102, 0)

    self.X = x
    self.Y = y
    self.particleSystem:setPosition(self.X, self.Y)

    self.min = 20
    self.max = 20  -- Emit 20 particles as defined in the original setup
end

function Splash:update(dt)
    self.particleSystem:update(dt)
end

function Splash:emit()
    -- Emit a fixed number of particles (20 as per the original effect)
    self.particleSystem:emit(20)
end

function Splash:draw()
    
    love.graphics.draw(self.particleSystem)
end

return Splash
