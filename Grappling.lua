Grappling = Class{}

HOOK_SPEED = 700
MAX_DISTANCE = 600
WINDOW_WIDTH = 1080
WINDOW_HEIGHT = 720
MAP_WIDTH = 15
MAP_HEIGHT = 10

function Grappling:init()
    self.state = "Retract"
    self.image = love.graphics.newImage("Powerups/Graphics/Hook1.png")
    self.dX = 0
    self.dY = 0
    self.flat_hor = false
    self.flat_vert = false
end

function Grappling:throw()
    local temp = player.player_width/2


    self.x_start = player.room_x + temp
    self.y_start = player.room_y + player.player_height/2
    self.x_click = love.mouse.getX()
    self.y_click = love.mouse.getY()
    self.map_x = player.map_x
    self.map_y = player.map_y
    self.dX = self.x_click - self.x_start
    self.dY = self.y_click - self.y_start

    self.slope = self.dX/self.dY

    self.angle = math.atan(self.slope)

    if self.dX < 0 then
        self.angle = math.atan(self.dY/self.dX) + PI
    elseif self.dX > 0 then
        self.angle = math.atan(self.dY/self.dX) 
    elseif self.dY > 0 then
        self.angle = PI/2
    else
        self.angle = 3*PI/2
    end



    if self.dX == 0 then
        self.flat_hor = true
    elseif self.dY == 0 then
        self.flat_vert = true
    end



    self.x_end = self.x_start
    self.y_end = self.y_start
    self.state = "Throw"

    self.x_temp = player.room_x
    self.y_temp = player.room_y

    if self.dY > 0 then
        self.state = "Retract"
    end
end

function Grappling:travel_hit(dt)

    local temp = 0

    if self.dX >= 0 then
        player.X_SCALE = -1
    else
        player.X_SCALE = 1
    end

    temp = player.player_width/2

    self.x_start = player.room_x + temp
    self.y_start = player.room_y + player.player_height/2


    self.dX = self.x_click - self.x_temp
    self.dY = self.y_click - self.y_temp

    self.slope = self.dX/self.dY

    self.angle = math.atan(self.slope)

    if self.dX < 0 then
        self.angle = math.atan(self.dY/self.dX) + PI
    elseif self.dX > 0 then
        self.angle = math.atan(self.dY/self.dX) 
    elseif self.dY > 0 then
        self.angle = PI/2
    else
        self.angle = 3*PI/2
    end

    dX = HOOK_SPEED * dt * math.cos(self.angle)
    dY = HOOK_SPEED * dt * math.sin(self.angle)
    local move = false
    local hit = false

    if self.state == "Throw" then
        while self.x_end + dX > WINDOW_WIDTH or self.y_end + dY > WINDOW_HEIGHT or self.x_end + dX < 1 or self.y_end + dY < 1 do
            dX = dX/2
            dY = dY/2

        end


        while (math.abs(dX) > 0.1 or math.abs(dY) > 0.1) and move == false do
            if maps[self.map_y][self.map_x].layout[math.ceil((dY+self.y_end)/(WINDOW_HEIGHT/MAP_HEIGHT))][math.ceil((dX+self.x_end)/(WINDOW_WIDTH/MAP_WIDTH))] <= 0 then
                self.x_end = self.x_end + dX
                self.y_end = self.y_end + dY
                move = true
            else
                dX = 4*dX/5
                dY = 4*dY/5
                hit = true
            end 
        end
        if hit == true then
            self.dX = self.x_end - self.x_start
            self.dY = self.y_end - self.y_start

            self.state = "Hit"
        end
    end

    
    local distanceX = self.x_end - self.x_start
    local distanceY = self.y_end - self.y_start
    local distance = ((distanceX*distanceX) + (distanceY*distanceY))^.5

    if distance > MAX_DISTANCE then
        self.state = "Retract"
    end
        


    if self.x_end >= WINDOW_WIDTH - 20 then
        self.state = "Retract"
    elseif self.x_end <= 20 then
        self.state = "Retract"
    end

    if self.y_end >= WINDOW_HEIGHT - 20 then
        self.state = "Retract"
    elseif self.y_end <= 10 then
        self.state = "Retract"
    end
end

function Grappling:swing(dt)
    if self.state == "Hit" then
        
        self.x_start = player.room_x + player.player_width/2
        self.y_start = player.room_y + player.player_height/2
    
        self.dX = self.x_end - self.x_start
        local temp = 0
    
        if self.dX >= 0 then
            player.X_SCALE = -1
        else
            player.X_SCALE = 1
        end
    
        temp = player.player_width/2

        self.x_start = player.room_x + temp

        self.dY = self.y_end - self.y_start


    
        if self.dX < 0 then
            self.angle = math.atan(self.dY/self.dX) + PI
        else
            self.angle = math.atan(self.dY/self.dX) 
        end
    
        player.dX = HOOK_SPEED * math.cos(self.angle)
        player.dY = HOOK_SPEED * math.sin(self.angle)


    end
end

function Grappling:render()
    love.graphics.setColor(.3, .1, .1, 1)
    love.graphics.line(self.x_start, self.y_start, self.x_end, self.y_end)

end

function Grappling:gun_render()
    local angle = nil
    if self.state ~= "Retract" then
        angle = self.angle
        love.graphics.draw(self.image, math.floor(self.x_end), math.floor(self.y_end), angle + PI/2, 1, 1, 36, 36)
    end
end