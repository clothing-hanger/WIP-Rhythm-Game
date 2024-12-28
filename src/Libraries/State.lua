-- Short and sweet state library for LÖVE. States and substates supported! (Substate draws above the state)
-- GuglioIsStupid - 2023
-- Version: 1.1.1
--[[

The MIT License (MIT)

=====================

Copyright © 2023 GuglioIsStupid

Permission is hereby granted, free of charge, to any person obtaining a copy of this software 
and associated documentation files (the “Software”), to deal in the Software without 
restriction, including without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the 
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or 
substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING 
BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

]]

---@alias State table
---@class state
local state = {} -- The state library
state.__index = state -- Allows us to call state functions as if they were global
state.__storage = {} -- Storage for previous states that were pushed

---@type any
local current = nil -- Current state

---@type any
local last = nil -- Last state

---@type any
local substate = nil -- Current substate

---@type boolean
state.inSubstate = false -- If we are in a substate

---@param newstate State
---@param ... any
---@return State
local function switch(newstate, ...)
    if current and current.exit then current:exit() end 
    last = current
    current = newstate
    if current.enter then current:enter(last, ...) end
    return current
end

---@param newState State
---@param ... any
---@return State
local function pop(newState, ...)
    if current and current.exit then current:exit() end
    last = current
    current = newState
    if current.reload then current:reload(last, ...) end
    return current
end

---Switches to a new state, returns the new state
---@param newstate State
---@param ... any
---@return State
function state.switch(newstate, ...)
    assert(newstate, "Called state.switch with no state")
    assert(type(newstate) == "table", "Called state.switch with invalid state")
    switch(newstate, ...)
    return current
end

---Pushes a new state, keeping the old one in storage
---@param newstate State
---@param ... any
---@return State
function state.push(newstate, ...)
    assert(newstate, "Called state.push with no state")
    assert(type(newstate) == "table", "Called state.push with invalid state")
    table.insert(state.__storage, current)
    switch(newstate, ...)
    return current
end

---Pops the current state, returns the new state
---@return State
function state.pop()
    assert(#state.__storage > 0, "Called state.pop with no states in storage")
    return pop(table.remove(state.__storage))
end

---Pops all states, returns the new state
---@return State
function state.popAll()
    assert(#state.__storage > 0, "Called state.popAll with no states in storage")
    return pop(table.remove(state.__storage, 1))
end

---Returns the current state
---@return State
function state.current() return current end

---Returns the last state
---@return State
function state.last() return last end

---Kills the current substate and calls current:substateReturn, returns nothing
---@param ... any
---@return nil
function state.killSubstate(...)
    if substate and substate.exit then substate:exit() end
    substate = nil
    state.inSubstate = false
    if current.substateReturn then current:substateReturn(...) end
end 

---Returns the current substate
---@return State
function state.currentSubstate() return substate end


---Returns to the last state, returns the new state
---@return State
function state.returnToLast()
    assert(last, "Called state.return with no last state")
    switch(last)
    return current
end

---Switches to a new substate, returns the new substate
---@param newstate State
---@param ... any
---@return State
function state.substate(newstate, ...)
    assert(newstate, "Called state.substate with no state")
    assert(type(newstate) == "table", "Called state.substate with invalid state") 
    substate = newstate -- Set the substate
    state.inSubstate = true
    if substate.enter then substate:enter(...) end
    return substate
end

---Creates a new state object (table)
local function new(name)
    local name = name or ("State." .. string.format("%x", math.random(0, 0xFFFFFFFF)))
    return setmetatable({}, {
        __tostring = function() 
            return name
        end,
        __call = function(_, ...)
            return state.switch(_, ...)
        end,
        __name = name
    })
end

---@diagnostic disable-next-line: deprecated
local unpack = table.unpack or unpack
setmetatable(state, { -- Allows you to call state functions as if they were global
    __index = function(_, func)
        -- return function(...) return (current[func] or nop)(...) end
        -- call substate and current state (substate calls above current state)
        return function(...)
            local args = {...} -- Allows us to pass arguments to the function
            local function f() -- Allows us to call both current and substate
                if current and current[func] then current[func](current, unpack(args)) end -- Call current state
                if substate and substate[func] then substate[func](substate, unpack(args)) end -- Call substate
            end
            return f()
        end
    end,

    -- when state is called as a function, return new, just makes the state definition look nicer
    __call = function(name) return new(name) end
})

return state