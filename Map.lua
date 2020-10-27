Map = Class{}

IMAGE_DIMENSION = 72

function Map:init(layout, window_width, window_height)
    self.screenwidth = 15
    self.screenheight = 10
    self.layout = layout
    self.x_scale = (1080 / self.screenwidth)
    self.y_scale = (720 / self.screenheight)
    color = 1

end

function Map:give_tile(i, j)
    return self.layout[i][j]
end

function Map:beautify()
    local i = 1
    local j = 1
    for i = 1, #self.layout do
        for j = 1, #self.layout[i] do
            if self.layout[i][j] == 1 then
                local _ = math.random(1, 4)

                if _ ~= 1 then
                    _ = _ + 4
                end

                self.layout[i][j] = _
            end
        end
    end
end


function Map:palette()
    if player.map_x == 4 and player.map_y == 3 then
        color = 1
    elseif player.map_x == 5 and player.map_y == 3 then
        color = 2
    elseif player.map_x == 5 and player.map_y == 7 then
        color = 3
    elseif player.map_x == 5 and player.map_y == 6 then
        color = 2
    elseif player.map_x == 1 and player.map_y == 6 then
        color = 1
    elseif player.map_x == 1 and player.map_y == 7 then
        color = 3
    end
end

function Map:render()
    love.graphics.setColor(1, 1, 1, 1)
    self:palette()


    local y = 1
    for y = 1, #self.layout do
        local x = 1
        for x = 1, #self.layout[1] do
            local map_tile = self.layout[y][x]
            if map_tile ~= 0 then 

                if color == 1 then
                    love.graphics.setColor(.8, .8, .9, 1)
                elseif color == 2 then
                    love.graphics.setColor(.9, .8, .8, 1)
                else
                    love.graphics.setColor(.8, .9, .8, 1)
                end
                if map_tile == 5 then
                    love.graphics.setColor(.95, .95, .95, 1)
                end

                
                
                love.graphics.draw(Tiles[map_tile], (x-1)*self.x_scale, (y-1)*self.y_scale, 0, self.x_scale/IMAGE_DIMENSION, self.y_scale/IMAGE_DIMENSION)
            end
        end
    end

end