Bullets = Class{}

PI = 3.1415
BULLET_SPEED = 400
BULLET_HEIGHT = 12
BULLET_WIDTH = 12

WINDOW_WIDTH = 1080
WINDOW_HEIGHT = 720
MAP_WIDTH = 15
MAP_HEIGHT = 10

function Bullets:init(room_x, room_y, map_x, map_y, bullet_number, offset, type, x_end, y_end)
    self.x_current = room_x
    self.y_current = room_y

    self.map_x = map_x
    self.map_y = map_y

    self.x_end = x_end
    self.y_end = y_end

    self.bullet_number = bullet_number

    self.type = type

    self.angle = nil

    if self.type == "Rocket" then
        self.image = bullet_images[3]
        self.damage = 2
        self.speed_multiply = .1
        self.acceleration = .7
    elseif self.type == "Pistol" then
        self.image = bullet_images[1]
        self.damage = 1
        self.speed_multiply = 1.2
    elseif self.type == "Shotgun" then
        self.image = bullet_images[2]
        self.damage = 1
        self.speed_multiply = .9
        self.acceleration = -.05
    elseif self.type == "Freeze" then
        self.image = bullet_images[4]
        self.damage = 0
        self.speed_multiply = .85
    elseif self.type == "Enemy" then
        self.image = bullet_images[5]
        self.damage = 1
        self.speed_multiply = .7
    end

    self.state = "Travel"

    self.offset = offset
    self.shot = false

end

function Bullets:fire(width, height)

    self.x_current = self.x_current + width
    self.y_current = self.y_current + height



    local dY = (self.y_end-self.y_current)
    local dX = (self.x_end-self.x_current)

    if dX < 0 then
        self.angle = math.atan(dY/dX) + PI + self.offset
        
    else
        self.angle = math.atan(dY/dX) + self.offset
    end
    
    local offset = 0

    if player.X_SCALE == -1 then
        offset = PI/4
    end

    self.x_current = self.x_current + math.cos(self.angle - .1*PI + offset)*26.1
    self.y_current = self.y_current + math.sin(self.angle - .1*PI + offset)*26.1
end

function Bullets:wall_collision(dt)
    if self.type == "Rocket" or self.type == "Shotgun" then
        self.speed_multiply = self.acceleration*dt + self.speed_multiply
    end
    local dY = math.sin(self.angle)*BULLET_SPEED*dt*self.speed_multiply
    local dX = math.cos(self.angle)*BULLET_SPEED*dt*self.speed_multiply



    if self.x_current > WINDOW_WIDTH - 30 or self.x_current < 30 or self.y_current > WINDOW_HEIGHT - 30 or self.y_current < 30 then
        self.state = "Wall Hit"
        player.bullet_fired[self.bullet_number] = false
        if self.type == "Enemy" then
            self.shot = false
        end

    end

    while self.x_current + dX > WINDOW_WIDTH or self.y_current + dX > WINDOW_HEIGHT or self.x_current + dX < 1 or self.y_current + dY < 1 do
        dX = dX/2
        dY = dY/2
    end

    

    if self.state == "Travel" then
        local tile = maps[self.map_y][self.map_x].layout[math.ceil((dY+self.y_current)/(WINDOW_HEIGHT/MAP_HEIGHT))][math.ceil((dX+self.x_current)/(WINDOW_WIDTH/MAP_WIDTH))]
        if  tile <= 0 then
            self.x_current = self.x_current + dX
            self.y_current = self.y_current + dY
        else
            if self.type == "Rocket" then
                love.audio.stop(sound_effects['Wall Break'])
                love.audio.play(sound_effects['Wall Break'])
                if tile == 5 then
                    maps[self.map_y][self.map_x].layout[math.ceil((dY+self.y_current)/(WINDOW_HEIGHT/MAP_HEIGHT))][math.ceil((dX+self.x_current)/(WINDOW_WIDTH/MAP_WIDTH))] = 0
                end
            else
                love.audio.stop(sound_effects['wall hit'])
                love.audio.play(sound_effects['wall hit'])
            end
            self.state = "Wall Hit"

            self.shot = false
            
            player.bullet_fired[self.bullet_number] = false

            if self.type == "Enemy" then
                Final_boss.bullet_fired[self.bullet_number] = false
            end
        end
    end

    
    local j = 1
    while j <= #enemies_in_room do
        local enemy_x = enemies_in_room[j].room_x
        local enemy_y = enemies_in_room[j].room_y
        local enemy_width = enemies_in_room[j].width
        local enemy_height = enemies_in_room[j].height
        local enemy_health = enemies_in_room[j].health
        if self.x_current > enemy_x and self.x_current < enemy_x + enemy_width and self.y_current > enemy_y and self.y_current < enemy_y + enemy_height and self.state == "Travel" and self.type ~= "Enemy" then
            self.state = "Enemy Hit"
            enemy_health = enemy_health - self.damage
            player.bullet_fired[self.bullet_number] = false
            if enemy_health <= 0 then
                enemies_in_room[j].state = "Normal"
                table.remove(enemies_in_room, j)
                love.audio.stop(sound_effects['Enemy Death'])
                love.audio.play(sound_effects['Enemy Death'])
                if math.random(1, 3) == 2 then
                    player.health = player.health + 1
                    player.health = math.min(player.health, player.health_packs)
                    love.audio.play(sound_effects['Health Get'])
                end
            else
                if self.type == "Freeze" then
                    enemies_in_room[j].state = "Freeze"
                    enemies_in_room[j].freeze_timer = 4
                end
                enemies_in_room[j].health = enemy_health
                love.audio.stop(sound_effects['Enemy Hit'])
                love.audio.play(sound_effects['Enemy Hit'])
            end
            
        end 
        j = j + 1
    end

    if self.type ~= "Enemy" and self.state == "Travel" then
        if player.map_x == Final_boss.map_x and player.map_y == Final_boss.map_y then
            if self.x_current > Final_boss.room_x and self.x_current < Final_boss.room_x + Final_boss.player_width and self.y_current > Final_boss.room_y and self.y_current < Final_boss.room_y + Final_boss.player_height then
                Final_boss.health = Final_boss.health - self.damage
                player.bullet_fired[self.bullet_number] = false
                self.state = "Enemy Hit"
                love.audio.stop(sound_effects['Boss hit'])
                love.audio.play(sound_effects['Boss hit'])

                if Final_boss.health <= 0 then
                    player.map_x = 8
                    player.map_y = 3
                    love.audio.play(sound_effects['Boss death'])
                end
            end
        end
    end

    if self.type == "Enemy" and self.state == "Travel" then
        if self.x_current > player.room_x and self.x_current < player.room_x + player.player_width and self.y_current > player.room_y and self.y_current < player.room_y + player.player_height then
            player.health = player.health - 1
            player.timer['Hurt'] = 3
            love.audio.play(sound_effects['Hurt'])
            self.state = "Player Hit"
            self.shot = false
            Final_boss.bullet_fired[self.bullet_number] = false
        end
    end
end

function Bullets:render()
    if self.state == "Travel" then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(self.image, self.x_current, self.y_current, self.angle, .5, .5, BULLET_WIDTH/2, BULLET_HEIGHT-4/2)
    end
end