local Splash = Class:extend()

function Splash:new(lane)
    self.particleSystem = love.graphics.newParticleSystem(Skin.Particles["Note Splash"])
    local gravity = 200

    self:setupColors(1)
    self.X = LanesPositions[States.Game.PlayState.inputMode][lane]
    self.Y = States.Game.PlayState.strumYPosition + 20
    self.lane = lane
    self.particleSystem:setPosition(self.X, self.Y)
    self.particleSystem:setSpeed(125, 150)
    self.particleSystem:setParticleLifetime(0.45, 0.5)
    self.particleSystem:setLinearAcceleration(-70, gravity, 50, gravity)
    self.particleSystem:setSpread(math.rad(360))
    self.min = 1
    self.max = 3
    self.particleSystem:setSizes(0.3, 0.25)
end

function Splash:setupColors(noteTime)
    for Judgement = 1, #JudgementNames do
        local judgement = Judgements[JudgementNames[Judgement]]

        if noteTime <= judgement.Timing then
            local color = judgement.Color
            self.colorS = {color[1], color[2], color[3], 1}
            self.colorT = {color[1], color[2], color[3], 0}
            self.particleSystem:setColors(self.colorS, self.colorT)
            break
        end
    end
end

function Splash:update(dt)
    self.particleSystem:update(dt)
end

function Splash:emit(noteTime)
    self:setupColors(noteTime)
    
    local amount = love.math.random(self.min, self.max)
    self.particleSystem:emit(amount)
end

function Splash:draw()
    love.graphics.draw(self.particleSystem)
end

return Splash
