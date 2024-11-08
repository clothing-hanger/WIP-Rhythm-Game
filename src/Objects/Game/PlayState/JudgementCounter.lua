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
end

function JudgementCounter:update(dt)

end

function JudgementCounter:bumpJudgement(judgement)
    self.judgementBumpPositions[judgement] = Skin.Params["Judgement Counter Bump Amount"]
end

function JudgementCounter:draw()
    local align
    if Skin.Params["Judgement Counter X"] < Inits.GameWidth/2 then -- counter is on left
        align = "left"
    else                                                           -- counter is on right
        align = "right"
    end

    for i = 1,#JudgementNames do
        local spacing = Skin.Params["Judgement Counter Spacing"]
        local y = Skin.Params["Judgement Counter Y"]
        local x = Skin.Params["Judgement Counter X"]
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