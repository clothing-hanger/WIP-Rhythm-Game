function InitializeJudgments()
    print("InitializeJudgments()")

    Judgements = {
        ["Marvelous"] = {
            Judgement = "Marvelous",
            Abbreviation = "MV",
            Timing = 26,
            Score = 1,
            Count = 0,
            ID = 1,
            Color = Skin.Params["Marvelous Color"],
            Health = 0.01,
        },
        ["Perfect"] = {
            Judgement = "Perfect",
            Abbreviation = "PF",
            Timing = 56,
            Score = 0.8,
            Count = 0,
            ID = 2,
            Color = Skin.Params["Perfect Color"],
            Health = 0.005,
        },
        ["Great"] = {
            Judgement = "Great",
            Abbreviation = "GR",
            Timing = 86,
            Score = 0.6,
            Count = 0,
            ID = 3,
            Color = Skin.Params["Great Color"],
            Health = -0.01,
        },
        ["Good"] = {
            Judgement = "Good",
            Abbreviation = "GD",
            Timing = 106,
            Score = 0.4,
            Count = 0,
            ID = 4,
            Color = Skin.Params["Good Color"],
            Health = -0.03,

        },
        ["Okay"] = {
            Judgement = "Okay",
            Abbreviation = "OK",
            Timing = 126,
            Score = 0.2,
            Count = 0,
            ID = 5,
            Color = Skin.Params["Okay Color"],
            Health = -0.07,
        },
        ["Miss"] = {
            Judgement = "Miss",
            Abbreviation = "MS",
            Timing = 146,
            Score = 0,
            Count = 0,
            ID = 6,
            Color = Skin.Params["Miss Color"],
            Health = -0.12,
        }
    }

    local judgementsArray = {}
    for k, v in pairs(Judgements) do
        table.insert(judgementsArray, v)
    end

    table.sort(judgementsArray, function(a, b)
        return a.ID < b.ID
    end)

    JudgementNames = {}
    for i, judgement in ipairs(judgementsArray) do
        table.insert(JudgementNames, judgement.Judgement)
    end
end