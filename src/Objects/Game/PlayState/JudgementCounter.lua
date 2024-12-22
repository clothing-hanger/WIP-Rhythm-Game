local JudgementCounter = Class:extend()

function JudgementCounter:new()
    self.judgementBumpPositions = {
        ["Marvelous"] = 0,
        ["Perfect"] = 0,
        ["Great"] = 0,
        ["Good"] = 0,
        ["Okay"] = 0,
        ["Miss"] = 0
    }

    self.x = Skin.Params["Judgement Counter X"]
    self.y = Skin.Params["Judgement Counter Y"]
    self.spacing = Skin.Params["Judgement Counter Spacing"]
    self.bumpAmount = Skin.Params["Judgement Counter Bump Amount"]
end

function JudgementCounter:update(dt)
end

function JudgementCounter:bumpJudgement(judgement)
    --[[
    print("begin print judgement")
    print(judgement)        -- why the FUCK DOES THIS NOT WORK 
    print("end print judgement")
    --[
    self.judgementBumpPositions[judgement] = self.bumpAmount
    for judgementName, amount in pairs(self.judgementBumpPositions) do
        print(judgementName)
        local tweenTime = Skin.Params["Judgement Counter Tween Time"] or 0.65
        local tweenType = Skin.Params["Judgement Counter Tween Type"] or "out-quad"
        --local bumpTween = Timer.tween(tweenTime, self.judgementBumpPositions[judgementName], {0}, tweenType)
        
        -- judgementName is nil sometimes???? i dont understand 😭
        
        if bumpTween then Timer.cancel(bumpTween) end
    end
    --]]
end

function JudgementCounter:draw()
    local align
    love.graphics.setColor(1,1,1)
    if self.x < Inits.GameWidth/2 then-- counter is on left
        align = "left"
    else                              -- counter is on right (fucking obviously if its not on the left its on the right)
        align = "right"
    end
    love.graphics.setFont(Skin.Fonts["Judgement Counter"])
    for i = 1,#JudgementNames do
        local spacing = self.spacing
        local x = self.x
        local y = self.y
        local text
        if Judgements[JudgementNames[i]].Count > 0 then
            text = Judgements[JudgementNames[i]].Count
        else
            text = Judgements[JudgementNames[i]].Abbreviation   -- print the judgement's name instead of 0
        end
        love.graphics.printf(text, x, y + (spacing * (i-1)), 200, align)
    end
end

return JudgementCounter