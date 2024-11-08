return {
    Game = {
        --PlayState
        Note = require("Objects.Game.PlayState.Note"),
        Receptor = require("Objects.Game.PlayState.Receptor"),
        ScrollVelocity = require("Objects.Game.PlayState.ScrollVelocity"),
        Judgement = require("Objects.Game.PlayState.Judgement"),
        Background = require("Objects.Game.PlayState.Background"),
        HUD = require("Objects.Game.PlayState.HUD"),
        ComboAlert = require("Objects.Game.PlayState.ComboAlert"),
        Combo = require("Objects.Game.PlayState.Combo"),
        HitErrorMeter = require("Objects.Game.PlayState.HitErrorMeter"),
        HealthBar = require("Objects.Game.PlayState.HealthBar"),
        NoteUnderlay = require("Objects.Game.PlayState.NoteUnderlay"),
        JudgementCounter = require("Objects.Game.PlayState.JudgementCounter"),

        --Particles
        Splash = require("Objects.Game.PlayState.Particles.Splash"),
        ComboAlertParticle = require("Objects.Game.PlayState.Particles.ComboAlert"),
        HealthParticle = require("Objects.Game.PlayState.Particles.HealthParticle"),

        --Results
        NoteHitPlot = require("Objects.Game.Results.NoteHitPlot"),
        JudgementBarGraph = require("Objects.Game.Results.JudgementBarGraph"),

    },
    Menu = {
        SongButton = require("Objects.Menu.SongButton"),
        DifficultyButton = require("Objects.Menu.DifficultyButton"),
        ModifiersMenu = require("Objects.Menu.ModifiersMenu"),
        ListMenu = require("Objects.Menu.ListMenu"),
        Visualizer = require("Objects.Menu.Visualizer"),
        SongPreview = require("Objects.Menu.SongPreview"),
    },
    Misc = {
        -- imagine being the Objects.Misc table lmao stupid ass empty useless fuck
    },
    UI = {
        Slider = require("Objects.UI.Slider"),
        Toggle = require("Objects.UI.Toggle"),
        Select = require("Objects.UI.Select"),
        TextBox = require("Objects.UI.TextBox"),
    },
}