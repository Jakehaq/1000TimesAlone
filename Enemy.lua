Enemy = Class{}

WINDOW_WIDTH = 1080
WINDOW_HEIGHT = 720
MAP_WIDTH = 15
MAP_HEIGHT = 10
XSCALE = WINDOW_WIDTH/MAP_WIDTH
YSCALE = WINDOW_HEIGHT/MAP_HEIGHT
PI = 3.1415

NORMAL = 1
CIRCLE = 2
CHASE = 3
SHOOT = 4

function Enemy:init(room_x, room_y, map_x, map_y, type, direction)
    self.room_x = room_x
    self.room_y = room_y
    self.map_x = map_x
    self.map_y = map_y
    self.type = type
    self.state = "Normal"

    if self.type == NORMAL then
        self.health = 5
        self.sprite = enemy_sprites[NORMAL]
        self.speed = 175
        self.width = 72
        self.height = 72
    end

    if self.type == CIRCLE then
        self.health = 4
        self.sprite = enemy_sprites[CIRCLE]
        self.speed = 175
        self.width = 72
        self.height = 72
    end

    if self.type == CHASE then
        self.health = 8
        self.sprite = enemy_sprites[CHASE]
        self.speed = 175
        self.width = 72
        self.height = 72
        self.distance = 500
    end

    if self.type == SHOOT then
        self.health = 7
        self.sprite = enemy_sprites[SHOOT]
        self.speed = 50
        self.width = 72
        self.height = 72
        self.bullet = Bullets()
        self.distance = 0
        self.shot_timer = 0
        self.shot_timer_reset = 2.4
    end

    self.direction = direction
    self.frame_number = 1
    self.animation_timer = .20
    self.freeze_timer = 0
end

function Enemy:move_collide(dt)
    if self.type == CIRCLE then
        self.direction = self.direction + PI*dt/8
    end


    self.dX = math.cos(self.direction) * self.speed * dt
    self.dY = math.sin(self.direction) * self.speed * dt

    local move = false
    local hit = false
    
    if self.type == CHASE or self.type == SHOOT then 
            local dY = (player.room_y - self.room_y)
            local dX = (player.room_x - self.room_x)
        
            if dX < 0 then
                self.direction = math.atan(dY/dX) + PI 
            else
                self.direction = math.atan(dY/dX) 
            end

            

            local distance = (dX*dX + dY*dY)^.5

            if distance < self.distance then
                self.dX = math.cos(self.direction) * self.speed * dt
                self.dY = math.sin(self.direction) * self.speed * dt
            else
                self.dX = 0
                self.dY = 0
            end
    end

    if math.abs(self.dX) < .1 then
        self.dX = 0
    end

    if math.abs(self.dY) < .1 then
        self.dY = 0
    end



    while (math.abs(self.dY) > .5 or math.abs(self.dX) > .5) and move == false and self.type ~= CHASE do

        if self.dY + self.room_y >= 0 and self.dY + self.room_y + self.height <= WINDOW_HEIGHT and self.dX + self.room_x >= 0 and self.dX + self.room_x + self.width <= WINDOW_WIDTH then
            if maps[self.map_y][self.map_x].layout[math.ceil((self.room_y + self.dY)/YSCALE)][math.ceil((self.room_x + self.dX)/XSCALE)] == 0  then

                if maps[self.map_y][self.map_x].layout[math.ceil((self.room_y + self.dY)/YSCALE)][math.ceil((self.room_x + self.dX + self.width)/XSCALE)] == 0 then

                    if maps[self.map_y][self.map_x].layout[math.ceil((self.room_y + self.dY + self.height)/YSCALE)][math.ceil((self.room_x + self.dX + self.width)/XSCALE)] == 0  then

                        if maps[self.map_y][self.map_x].layout[math.ceil((self.room_y + self.dY + self.height)/YSCALE)][math.ceil((self.room_x + self.dX)/XSCALE)] == 0 then
                            self.room_x = self.room_x + self.dX
                            self.room_y = self.room_y + self.dY
                            move = true
                        else
                            if hit == false then
                                self.direction = self.direction + PI
                                hit = true
                            end
                            self.dY = self.dY/2
                            self.dX = self.dX/2
                        end
                    else
                        if hit == false then
                            self.direction = self.direction + PI
                            hit = true
                        end
                        self.dY = self.dY/2
                        self.dX = self.dX/2
                    end
                else
                    if hit == false then
                        self.direction = self.direction + PI
                        hit = true
                    end
                    self.dY = self.dY/2
                    self.dX = self.dX/2
                end
            else
                if hit == false then
                    self.direction = self.direction + PI
                    hit = true
                end
                self.dY = self.dY/2
                self.dX = self.dX/2
            end
        else
            self.dY = self.dY/2
            self.dX = self.dX/2
        end

    end

    if self.type == CHASE then
        self.room_x = self.room_x + self.dX
        self.room_y = self.room_y + self.dY
    end

    if self.type == SHOOT then
        if self.frame_number == 7 and self.bullet.shot == false then
            self.bullet:init(self.room_x, self.room_y, self.map_x, self.map_y, 100, 0, "Enemy", player.room_x + player.player_width/2, player.room_y + player.player_height/2)
            self.bullet:fire(self.width/2, self.height/2)
            self.bullet.shot = true
            self.shot_timer = self.shot_timer_reset
            love.audio.stop(sound_effects['Enemy Shoot'])
            love.audio.play(sound_effects['Enemy Shoot'])
        end
        if self.bullet.shot == true then
            self.bullet:wall_collision(dt)
        end
        self.shot_timer = self.shot_timer -dt
    end



    

    local cosWidth = (math.abs(math.cos(self.direction))^2 * self.width)
    local sinWidth = (math.abs(math.sin(self.direction))^2 * self.width)
    local sinHeight = (math.abs(math.sin(self.direction))^2 * self.height)
    local cosHeight = (math.abs(math.cos(self.direction))^2 * self.height)

    if self.room_x + cosWidth + sinHeight > player.room_x and self.room_y + cosHeight +sinWidth > player.room_y and player.room_x + player.player_width > self.room_x and player.room_y + player.player_height > self.room_y then
        if player.timer['Hurt'] <= 0 then
            player.health = player.health - 1
            player.timer['Hurt'] = 3
            love.audio.play(sound_effects['Hurt'])

            if player.room_x < self.room_x then
                player.dX = -200
            else
                player.dX = 200
            end
            if player.room_y > self.room_y then
                player.dY = 150
            else
                player.dY = -150
            end
        end
    end

    if self.room_x < self.width + 10 or self.room_x > WINDOW_WIDTH - 10 - self.width or self.room_y < self.height + 10 or self.room_y > WINDOW_HEIGHT - self.height - 10 then
        self.direction = self.direction - PI
    end

end

function Enemy:defrost(dt)
    self.freeze_timer = self.freeze_timer - dt

    if self.freeze_timer <= 0 then
        self.state = "Normal"
    end
end

function Enemy:animation(dt)
    if self.type == SHOOT then
        if self.bullet.shot == true or self.shot_timer >= 0 then
            self.frame_number = 1
            self.animation_timer = .10
        end
    end
    self.animation_timer = self.animation_timer - dt
    if self.animation_timer <= 0 then
        self.animation_timer = .10
        self.frame_number = self.frame_number%(#self.sprite) + 1

    end
end

function Enemy:render()
    
    local direction = 0

    if self.type == CHASE or self.type == CIRCLE then
        direction = self.direction - PI/2
    elseif self.type == SHOOT then
        direction = self.direction - PI/9
    end

    if self.state == "Freeze" then
        love.graphics.setColor(.2, .4, .8, 1)
    else
        love.graphics.setColor(1, 1, 1, 1)
    end

    love.graphics.draw(self.sprite[self.frame_number], math.floor(self.room_x + self.width/2), math.floor(self.room_y + self.height/2), direction, self.width/XSCALE, self.height/YSCALE, self.width/2, self.height/2)

    if self.type == SHOOT and self.bullet.shot == true then
        self.bullet:render()
    end
end
