Items = Class{}

WINDOW_WIDTH = 1080
WINDOW_HEIGHT = 720
MAP_WIDTH = 15
MAP_HEIGHT = 10
XSCALE = WINDOW_WIDTH/MAP_WIDTH
YSCALE = WINDOW_HEIGHT/MAP_HEIGHT

function Items:init(input_x, input_y, room_x, room_y, name, image, explanation)

    self.position_x = input_x
    self.position_y = input_y
    self.map_x = room_x
    self.map_y = room_y
    self.name = name
    self.image = image
    self.collected = false
    self.explanation = explanation
    self.explained = false
end

function Items:render()
    if self.name ~= "Info" then
        love.graphics.draw(self.image, math.floor((self.position_x-1)*XSCALE), math.floor((self.position_y-1)*YSCALE), 0)
    end
end

function Items:explain()
    love.graphics.setColor(0, 0, .15, 1)
    love.graphics.rectangle('fill', 100, 110, 900, 400)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle('fill', 120, 130, 860, 360)

    love.graphics.setColor(1, 1, 1, 1)
    if self.name ~= "Info" then
        love.graphics.draw(self.image, 540 - 36, 200)
    end
    love.graphics.printf(self.explanation, 135, 300, 420, 'left', 0, 2)
    love.graphics.printf("(Press space to continue)", 120, 460, 860, 'center')
end