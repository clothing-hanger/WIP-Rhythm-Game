---@param colors table<number, number, number>
---@return table<number, number, number> colorsRGB
function rgb(colors)
    return {colors[1]/255, colors[2]/255, colors[3]/255}
end
