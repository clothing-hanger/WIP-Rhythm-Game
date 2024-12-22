return {
    Game = {
        PlayState = require("States.Game.Playstate"),
        Results = require("States.Game.Results"),
    },
    Menu = {
        SongSelect = require("States.Menu.SongSelect"),
        SettingsMenu = require("States.Menu.SettingsMenu"),
        TitleScreen = require("States.Menu.TitleScreen"),
        Intro = require("States.Menu.Intro"),
    },
    Misc = {
        PreLoader = require("States.Misc.PreLoader")
    },
}