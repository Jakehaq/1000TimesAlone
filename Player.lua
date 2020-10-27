Player = Class{}
require 'Bullets'

RUN_ACCEL = 1300
ACCEl = 1100
TOP_SPEED = 350
RUN_SPEED = 430
JUMP_SPEED = 470
GRAVITY = 500
FRICTION = 8
RUN_FRICTION = 5
WINDOW_WIDTH = 1080
WINDOW_HEIGHT = 720
MAP_HEIGHT = 10
MAP_WIDTH = 15
JUMP = 1
DOUBLE_JUMP = 2
GUN = 3
GRAPPLE = 4
DASH = 5
SHOTGUN = 6


FRAME_TIME = 0.08
RUN_FRAME_TIME = .06
X_SCALE = WINDOW_WIDTH/MAP_WIDTH
Y_SCALE = WINDOW_HEIGHT/MAP_HEIGHT

function Player:init(room_x, room_y, map_x, map_y)
    self.room_x = room_x
    self.room_y = room_y

    self.map_x = map_x
    self.map_y = map_y

    self.dY = 0
    self.dX = 0

    self.player_width = 60
    self.player_height = 124

    self.sprites = {{}, {}, {}, {}, {}, {}}
    self.arm_sprites = {{}, {}, {}, {}}
    self.animation_number = 1
    self.frame_number = 1
    self.X_SCALE = 1
    self.arm_frame = 0
    self.previous_animation = 1
    self.rotation = 0
    
    self.sprites[1][1] = love.graphics.newImage("Player/Idle/New_player1.png")

    self.sprites[2][1] = love.graphics.newImage("Player/Walk/Left/Left_1.png")
    self.sprites[2][2] = love.graphics.newImage("Player/Walk/Left/Left_2.png")
    self.sprites[2][3] = love.graphics.newImage("Player/Walk/Left/Left_1.png")
    self.sprites[2][4] = love.graphics.newImage("Player/Walk/Left/Left_4.png")
    self.sprites[2][5] = love.graphics.newImage("Player/Walk/Left/Left_5.png")
    self.sprites[2][6] = love.graphics.newImage("Player/Walk/Left/Left_6.png")
    self.sprites[2][7] = love.graphics.newImage("Player/Walk/Left/Left_5.png")
    self.sprites[2][8] = love.graphics.newImage("Player/Walk/Left/Left_4.png")

    self.sprites[3][1] = love.graphics.newImage("Player/Jump/New_Player_jump1.png")
    self.sprites[3][2] = love.graphics.newImage("Player/Jump/New_Player_jump2.png")
    self.sprites[3][3] = love.graphics.newImage("Player/Jump/New_Player_jump3.png")

    self.sprites[4][1] = love.graphics.newImage("Player/Shoot/Player_shoot_template2.png")
    self.sprites[4][2] = love.graphics.newImage("Player/Shoot/Player_shoot_template1.png")
    self.sprites[4][3] = love.graphics.newImage("Player/Shoot/Player_shoot_template2.png")
    self.sprites[4][4] = love.graphics.newImage("Player/Shoot/Player_shoot_template3.png")
    self.sprites[4][5] = love.graphics.newImage("Player/Shoot/Player_shoot_template4.png")
    self.sprites[4][6] = love.graphics.newImage("Player/Shoot/Player_shoot_template5.png")
    self.sprites[4][7] = love.graphics.newImage("Player/Shoot/Player_shoot_template4.png")
    self.sprites[4][8] = love.graphics.newImage("Player/Shoot/Player_shoot_template3.png")
    self.sprites[5][3] = love.graphics.newImage("Player/Shoot/Player_jump_shoot1.png")
    self.sprites[6][1] = love.graphics.newImage("Player/Idle/they_see_me_rollin1.png")
    
    self.arm_sprites[1][1] = love.graphics.newImage("Player/Shoot/arm_gun_template1.png")
    self.arm_sprites[1][2] = love.graphics.newImage("Player/Shoot/arm_gun_template2.png")
    self.arm_sprites[2][1] = love.graphics.newImage("Player/Shoot/arm_gun_template3.png")
    self.arm_sprites[2][2] = love.graphics.newImage("Player/Shoot/arm_gun_template4.png")
    self.arm_sprites[3][1] = love.graphics.newImage("Player/Shoot/arm_gun_template5.png")
    self.arm_sprites[4][1] = love.graphics.newImage("Player/Shoot/arm_gun_template6.png")
    

    self.gun_images = {}
    self.gun_images[1] = love.graphics.newImage("Powerups/Graphics/New_gun1.png")
    self.gun_images[2] = love.graphics.newImage("Powerups/Graphics/Shotgun1.png")
    self.gun_images[3] = love.graphics.newImage("Powerups/Graphics/Rocket_launcher1.png")
    self.gun_images[4] = love.graphics.newImage("Powerups/Graphics/Freeze_Ray1.png")
    

    self.health_packs = 5
    self.health = self.health_packs
    self.heart = love.graphics.newImage("Player/Heart1.png")

    self.double_jumped = false
    self.jumped = false
    self.dashed = false
    self.right_dash = false
    self.left_dash = false
    self.timer = {}
    self.timer[DOUBLE_JUMP] = 0
    self.timer['Hurt'] = 0
    self.timer['Dash'] = 0
    self.timer['Dashing'] = 0
    self.timer['Animation'] = .20
    self.timer['Shooting'] = 0
    self.in_air = false
    self.angle = 0

    self.max_bullets = 3
    self.bullets = {}
    self.bullet_fired = {}
    self.gun_selected = 1
    self.guns = {3, 6, 7, 8}
    self.shooting = false

    local i = 1
    for i = 1, 40 do
        self.bullets[i] = Bullets()
        self.bullet_fired[i] = false
    end
    

    
    self.save_health = self.health_packs
    self.health = self.health_packs
    self.save_bullets = self.max_bullets
    self.items_save = {}
    local i = 1
    for i = 1, 100 do
        self.items_save[i] = false
    end
    self.save_map_x = self.map_x
    self.save_map_y = self.map_y
    self.save_room_x = self.room_x
    self.save_room_y = self.room_y
end

function Player:map_collision(x_shift, y_shift)
    local collision_Xscale = X_SCALE
    local collision_Yscale = Y_SCALE

    local movement = false
    while math.abs(y_shift) > .1 and movement == false do

        if (self.player_height + y_shift + self.room_y) <= WINDOW_HEIGHT and self.room_y + y_shift >= 0 then
    
            if maps[self.map_y][self.map_x].layout[math.ceil((self.room_y + y_shift) / (collision_Yscale))][math.ceil(self.room_x / collision_Xscale)] <= 0 then

                if maps[self.map_y][self.map_x].layout[math.ceil((self.room_y + y_shift) / (collision_Yscale))][math.ceil((self.room_x+self.player_width) / (collision_Xscale))] <= 0 then

            
                    if maps[self.map_y][self.map_x].layout[math.ceil((self.room_y + y_shift + self.player_height) / (collision_Yscale))][math.ceil((self.room_x + self.player_width) / (collision_Xscale))] <= 0 then

                            if maps[self.map_y][self.map_x].layout[math.ceil((self.room_y + y_shift + self.player_height) / (collision_Yscale))][math.ceil(self.room_x / (collision_Xscale))] <= 0 then
                                self.room_y = self.room_y + y_shift
                                movement = true
                                self.in_air = true
                        
                            else
                                self.dY = 0
                                self.double_jumped = false
                                self.jumped = false
                                y_shift = y_shift/2
                                self.timer[DOUBLE_JUMP] = 0
                                grapple.state = "Retract"
                                self.dashed = false
                                self.in_air = false
                        
                            end
                
                        else
                            self.dY = 0
                            y_shift = y_shift/2
                            self.double_jumped = false
                            self.jumped = false
                            self.timer[DOUBLE_JUMP] = 0
                            grapple.state = "Retract"
                            self.dashed = false
                            self.in_air = false
                        end
                    else
                        self.dY = -.1
                        grapple.state = "Retract"
                        y_shift = y_shift/2
                    end
                else
                    self.dY = -.1
                    grapple.state = "Retract"
                    y_shift = y_shift/2
                end
        else
            y_shift = y_shift/2
        end


    end

    while (self.room_x + x_shift < 0 or self.room_x + self.player_width + x_shift > WINDOW_WIDTH ) do
        x_shift = x_shift/2
    end

    if maps[self.map_y][self.map_x].layout[math.ceil(self.room_y/collision_Yscale)][math.ceil((self.room_x + x_shift)/collision_Xscale)] <= 0 then

        if maps[self.map_y][self.map_x].layout[math.ceil(self.room_y/collision_Yscale)][math.ceil((self.room_x + self.player_width + x_shift)/collision_Xscale)] <= 0 then

            if maps[self.map_y][self.map_x].layout[math.ceil((self.room_y+self.player_height)/collision_Yscale)][math.ceil((self.room_x + self.player_width + x_shift)/collision_Xscale)] <= 0 then

                if maps[self.map_y][self.map_x].layout[math.ceil((self.room_y+self.player_height)/collision_Yscale)][math.ceil((self.room_x + x_shift)/collision_Xscale)] <= 0 then

                    if maps[self.map_y][self.map_x].layout[math.ceil((self.room_y+self.player_height/2)/collision_Yscale)][math.ceil((self.room_x + self.player_width + x_shift)/collision_Xscale)] <= 0 then

                        if maps[self.map_y][self.map_x].layout[math.ceil((self.room_y+self.player_height/2)/collision_Yscale)][math.ceil((self.room_x + x_shift)/collision_Xscale)] <= 0 then
        
                            self.room_x = self.room_x + x_shift
                        else
                            self.dX = self.dX/5
                            grapple.state = "Retract"
                        end
                    else
                        self.dX = self.dX/5
                        grapple.state = "Retract"
                    end
                else
                    self.dX = self.dX/5
                    grapple.state = "Retract"
                end
            else
                self.dX = self.dX/5
                grapple.state = "Retract"
            end
        else
            self.dX = self.dX/5
            grapple.state = "Retract"
        end
    else
        self.dX = self.dX/5
        grapple.state = "Retract"
    end
        
    
end

function Player:jump(key)
    if key == 'w' and items[JUMP].collected == true then
        if self.jumped == false then
            love.audio.stop(sound_effects['jump'])
            love.audio.play(sound_effects['jump'])
            self.dY = -JUMP_SPEED
            self.jumped = true
            self.double_jumped = false
        elseif self.jumped == true and items[DOUBLE_JUMP].collected == true and self.double_jumped == false then
            love.audio.stop(sound_effects['jump'])
            love.audio.play(sound_effects['jump'])
            self.dY = -JUMP_SPEED
            self.double_jumped = true
            self.replay_jump_anim = true
        end
    end
end

function Player:Shoot(dt)
    local i = 1
    for i = 1, self.max_bullets do
        if self.bullet_fired[i] == true then
            self.bullets[i]:wall_collision(dt)
        end
    end


    if left_clicked == true then
        local i = 1
        
        
        if self.gun_selected ~= 2 and (items[3].collected == true or items[7].collected == true or items[8].collected == true) then
            while self.bullet_fired[i] == true and i <= self.max_bullets do
                i = i + 1
            end
            if i <= self.max_bullets then

                local x_offset = 36
                local y_offset = 66

                if self.in_air == true then
                    if self.X_SCALE == 1 then
                        x_offset = 26
                    else
                        x_offset = 34
                    end
                    y_offset = 66
                else
                    if self.X_SCALE == -1 then
                        x_offset = 24
                    end
                end


                
                if self.gun_selected == 1 then
                    
                    self.bullets[i]:init(self.room_x + x_offset, self.room_y + y_offset, self.map_x, self.map_y, i, 0, "Pistol", love.mouse.getX(), love.mouse.getY())
                    love.audio.stop(sound_effects['shoot'])
                    love.audio.play(sound_effects['shoot'])
                elseif self.gun_selected == 3 then
                    self.bullets[i]:init(self.room_x + x_offset, self.room_y + y_offset, self.map_x, self.map_y, i, 0, "Rocket", love.mouse.getX(), love.mouse.getY())
                    love.audio.stop(sound_effects['Rocket'])
                    love.audio.play(sound_effects['Rocket'])
                else
                    self.bullets[i]:init(self.room_x + x_offset, self.room_y + y_offset, self.map_x, self.map_y, i, 0, "Freeze", love.mouse.getX(), love.mouse.getY())
                    love.audio.stop(sound_effects['Freeze'])
                    love.audio.play(sound_effects['Freeze'])
                end
                
                
                self.bullet_fired[i] = true
                self.shooting = true
                
                self.bullets[i]:fire(0, 0)
                self.angle = self.bullets[i].angle
            end
        elseif items[6].collected == true then
            local bullets = {}
            local j = 0
            while j < 3 and i <= self.max_bullets do
                while self.bullet_fired[i] == true and i <= self.max_bullets do
                    i = i + 1
                end
                if self.bullet_fired[i] == false then
                    j = j + 1
                end
                bullets[i] = true
                i = i + 1
                
            end
            if j == 3 then
                local x_offset = 36
                local y_offset = 66

                if self.in_air == true then
                    if self.X_SCALE == 1 then
                        x_offset = 26
                    else
                        x_offset = 34
                    end
                    y_offset = 66
                else
                    if self.X_SCALE == -1 then
                        x_offset = 24
                    end
                end
                local j = 0
                for i = 1, self.max_bullets do
                    if bullets[i] == true then
                        self.bullets[i]:init(self.room_x + x_offset, self.room_y + y_offset, self.map_x, self.map_y, i, (j-1)*PI/20, "Shotgun", love.mouse.getX(), love.mouse.getY())
                        
                        self.bullet_fired[i] = true
                        j = j + 1
                        self.shooting = true
                        self.bullets[i]:fire(0, 0)
                        if j == 2 then
                            self.angle = self.bullets[i].angle
                        end

                    end
                end
                love.audio.stop(sound_effects['Shotgun'])
                love.audio.play(sound_effects['Shotgun'])
            end
        end

            

        left_clicked = false
    end
end

function Player:controls(dt)

    if not love.keyboard.isDown('lshift')  then
        ACCEl = RUN_ACCEL
        TOP_SPEED = RUN_SPEED
        FRICTION = RUN_FRICTION
        FRAME_TIME = RUN_FRAME_TIME
    else
        ACCEl = 1100
        TOP_SPEED = 350
        FRICTION = 8
        FRAME_TIME = .08
    end

 

    player.timer['Dashing'] = player.timer['Dashing'] - dt
    player.timer['Dash'] = player.timer['Dash'] - dt

    if not love.keyboard.isDown() then
        if love.keyboard.isDown('a') then
            self.dX = -ACCEl*dt + self.dX
            if items[5].collected == true and self.dashed == false then
                self.timer['Dash'] = .1
                self.right_dash = false
                self.left_dash = true
            end
        end
    end

    if grapple.state ~= "Hit" and self.timer['Dashing'] <= 0 and self.dX < 0 then
        self.dX = math.max(self.dX, -TOP_SPEED)
    end

    if not love.keyboard.isDown() then
        if love.keyboard.isDown('d') then
            self.dX = ACCEl*dt + self.dX
            if items[5].collected == true and self.dashed == false then
                self.timer['Dash'] = .1
                self.right_dash = true
                self.left_dash = false
            end
        end
    end

    if grapple.state ~= "Hit" and self.timer['Dashing'] <= 0 and self.dX > 0 then
        self.dX = math.min(self.dX, TOP_SPEED)
    end
    
    if grapple.state == "Hit" then
        GRAVITY = 0
    else
        GRAVITY = 700
    end


    self.dY = self.dY + GRAVITY*dt

    if math.abs(self.dX) < 10 then
        self.dX = 0
    end

    if grapple.state ~= "Hit" and self.timer['Dashing'] <= 0 then
        self.dX = self.dX * (1-(FRICTION*dt))
    end

    local y_shift = self.dY*dt
    local x_shift = self.dX*dt

    self:map_collision(x_shift, y_shift)

    self:Shoot(dt)

end

function Player:Change_Map()
    if self.room_x >= WINDOW_WIDTH - 80 then
        self.map_x = self.map_x + 1
        self.room_x = 36
        grapple.state = "Retract"
        local i = 1
        for i = 1, self.max_bullets do
            self.bullets[i].state = "Wall Hit"
            self.bullet_fired[i] = false
        end
        enemies_in_room = {}
        Enemy_load()
        local i = 1
        local j = 1
        for i = 1, #enemies do
            if enemies[i].map_x == self.map_x and enemies[i].map_y == self.map_y then
                enemies_in_room[j] = enemies[i]
                j = j + 1
            end
        end

        if self.map_x == Final_boss.map_x and self.map_y == Final_boss.map_y then
            self.room_x = self.room_x + 72
        end

    elseif self.room_x <= 26 then
        self.map_x = self.map_x - 1
        self.room_x = WINDOW_WIDTH - 90
        grapple.state = "Retract"
        self.bullets.state = "Wall Hit"
        for i = 1, self.max_bullets do
            self.bullets[i].state = "Wall Hit"
            self.bullet_fired[i] = false
        end
        enemies_in_room = {}
        Enemy_load()
        local i = 1
        local j = 1
        for i = 1, #enemies do
            if enemies[i].map_x == self.map_x and enemies[i].map_y == self.map_y then
                enemies_in_room[j] = enemies[i]
                j = j + 1
            end
        end
    end

    if self.room_y >= WINDOW_HEIGHT - 130 then
        self.map_y = self.map_y + 1
        self.room_y = 20
        grapple.state = "Retract"
        self.bullets.state = "Wall Hit"
        for i = 1, self.max_bullets do
            self.bullets[i].state = "Wall Hit"
            self.bullet_fired[i] = false
        end
        local i = 1
        local j = 1
        enemies_in_room = {}
        Enemy_load()
        for i = 1, #enemies do
            if enemies[i].map_x == self.map_x and enemies[i].map_y == self.map_y then
                enemies_in_room[j] = enemies[i]
                j = j + 1
            end
        end
    elseif self.room_y <= 1 then
        self.map_y = self.map_y - 1
        self.room_y = WINDOW_HEIGHT - 135
        grapple.state = "Retract"
        self.bullets.state = "Wall Hit"
        self.dY = -460
        self.jumped = false
        self.in_air = true
        for i = 1, self.max_bullets do
            self.bullets[i].state = "Wall Hit"
            self.bullet_fired[i] = false
        end
        enemies_in_room = {}
        Enemy_load()
        local i = 1
        local j = 1
        for i = 1, #enemies do
            if enemies[i].map_x == self.map_x and enemies[i].map_y == self.map_y then
                enemies_in_room[j] = enemies[i]
                j = j + 1
            end
        end
    end

end

function Player:item_collect(item_choice)
    if self.room_x < (items[item_choice].position_x)*X_SCALE and self.room_x+self.player_width > (items[item_choice].position_x-1)*X_SCALE then
        if self.room_y < (items[item_choice].position_y)*Y_SCALE and self.room_y+self.player_height > (items[item_choice].position_y-1)*Y_SCALE then
            items[item_choice].collected = true
            love.audio.play(sound_effects['powerup'])
            explain = true
            if items[item_choice].name == "Info" then
                love.audio.stop(sound_effects['powerup'])
            end
            if items[item_choice].name == "Health Upgrade" then
                love.audio.stop(sound_effects['powerup'])
                love.audio.stop(sound_effects['Health Upgrade'])
                love.audio.play(sound_effects['Health Upgrade'])
                self.health_packs = self.health_packs + 1
                
            end
            if items[item_choice].name == "Ammo Upgrade" then
                love.audio.stop(sound_effects['powerup'])
                love.audio.stop(sound_effects['Health Upgrade'])
                love.audio.play(sound_effects['Health Upgrade'])
                self.max_bullets = self.max_bullets + 1
            end
            self.health = self.health_packs
        end
    end
end

function Player:save()
    if maps[self.map_y][self.map_x].layout[math.ceil(self.room_y/Y_SCALE)][math.ceil((self.room_x + self.player_width/2)/X_SCALE)] == -1 then
        self.save_health = self.health_packs
        self.health = self.health_packs
        self.save_bullets = self.max_bullets
        self.items_save = {}
        local i = 1
        for i = 1, #items do
            self.items_save[i] = items[i].collected
        end
        self.save_map_x = self.map_x
        self.save_map_y = self.map_y
        self.save_room_x = self.room_x
        self.save_room_y = self.room_y
        love.audio.play(sound_effects['Save'])
    end
end

function Player:death_check()
    if self.health <= 0 then
        self.health_packs = self.save_health 
        self.health = self.health_packs
        self.max_bullets = self.save_bullets
        local i = 1
        for i = 1, #items do
            items[i].collected = self.items_save[i]
            items[i].explained = items[i].collected
        end
        self.map_x = self.save_map_x
        self.map_y = self.save_map_y
        self.room_x = self.save_room_x
        self.room_y = self.save_room_y

        local i = 1

        grapple.state = "Retract"
        self.bullets.state = "Wall Hit"
        for i = 1, self.max_bullets do
            self.bullets[i].state = "Wall Hit"
            self.bullet_fired[i] = false
        end

        local j = 1
        enemies_in_room = {}
        Enemy_load()
        for i = 1, #enemies do
            if enemies[i].map_x == self.map_x and enemies[i].map_y == self.map_y then
                enemies_in_room[j] = enemies[i]
                j = j + 1
            end
        end

        self.dX = 0
        self.dY = 0

        Final_boss:init(500, 300, 8, 2)
    end
end

function Player:animation(dt)
    self.timer['Animation'] = self.timer['Animation'] - dt
    self.timer['Shooting'] = self.timer['Shooting'] - dt

    if self.dX > 0 then
        self.X_SCALE = -1
    elseif self.dX < 0 then
        self.X_SCALE = 1
    end

    if self.shooting == true then
        if self.animation_number ~= 4 and self.animation_number ~= 5 then
            self.previous_animation = self.animation_number
        end

        if self.previous_animation ~= 3 then
            self.animation_number = 4
            self.timer['Animation'] = FRAME_TIME
            self.arm_frame = 1
            self.timer['Shooting'] = .24
            self.shooting = false
        elseif self.in_air == true then
            self.animation_number = 5
            self.frame_number = 3
            self.timer['Animation'] = FRAME_TIME
            self.arm_frame = 1
            self.timer['Shooting'] = .24
            self.shooting = false
        else
            self.timer['Shooting'] = 0
            self.timer['Animation'] = 0
        end
        

    end

    if self.timer['Dashing'] >= 0 and self.timer['Shooting'] <= 0 then
        self.animation_number = 3
        self.frame_number = 3
        self.timer['Animation'] = .12
    elseif self.in_air == false and self.timer['Shooting'] <= 0 then
        if self.dX ~= 0 and self.animation_number ~= 2 then
            self.animation_number = 2
            self.frame_number = 1
        elseif self.dX == 0 and self.animation_number ~= 1 then
            self.animation_number = 1
            self.frame_number = 1
        end
    elseif self.timer['Shooting'] <= 0 then
        if (self.animation_number ~= 3) or self.replay_jump_anim == true  then
            self.frame_number = 1
            if self.animation_number == 5 then
                self.frame_number = 3
            end
            self.animation_number = 3
            
            self.timer['Animation'] = .10
            self.replay_jump_anim = false
        elseif (self.animation_number == 3 and self.frame_number == 3)  then
            self.timer['Animation'] = .10
        end
    else

    end



    if self.timer['Animation'] <= 0 then
        self.timer['Animation'] = FRAME_TIME
        self.frame_number = self.frame_number%(#self.sprites[self.animation_number]) + 1
        if self.timer['Shooting'] > 0 then
            self.arm_frame = self.arm_frame%(#self.arm_sprites[self.gun_selected]) + 1
        end
    end

    if (self.previous_animation == 1 or self.previous_animation == 3) then
        if self.animation_number == 4 then
            self.frame_number = 1
        elseif self.animation_number == 5 then
            self.frame_number = 3 
        end
    end
    

end

function Player:render()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.sprites[self.animation_number][self.frame_number], math.floor(self.room_x + self.player_width/2), math.floor(self.room_y - 1 + self.player_height/2), self.rotation, self.X_SCALE, 1, self.player_width/2, self.player_height/2)
    if (self.animation_number == 4) and self.X_SCALE == 1 then
        love.graphics.draw(self.arm_sprites[self.gun_selected][self.arm_frame], math.floor(self.room_x + self.player_width-24), math.floor(self.room_y + 66), self.angle - PI, 1, 1, 26, 0)
    elseif (self.animation_number == 4) and self.X_SCALE == -1 then
        love.graphics.draw(self.arm_sprites[self.gun_selected][self.arm_frame], math.floor(self.room_x + self.player_width-36), math.floor(self.room_y + 66), self.angle, self.X_SCALE, 1, 26, 0)
    elseif(self.animation_number == 5) and self.X_SCALE == 1 then
        love.graphics.draw(self.arm_sprites[self.gun_selected][self.arm_frame], math.floor(self.room_x + self.player_width-34), math.floor(self.room_y + 66), self.angle - PI, 1, 1, 26, 0)
    elseif (self.animation_number == 5) and self.X_SCALE == -1 then
        love.graphics.draw(self.arm_sprites[self.gun_selected][self.arm_frame], math.floor(self.room_x + self.player_width-26), math.floor(self.room_y + 66), self.angle, self.X_SCALE, 1, 26, 0)
    end
end

function Player:health_render()
    
    local i = 1
    local j = self.health
    for i = 1, self.health_packs do
        if j >= 1 then
            love.graphics.setColor(1, 1, 1, .95)
        else
            love.graphics.setColor(.2, 1, 1, .8)
        end
        love.graphics.draw(self.heart, 20 + 25*i, 30)
        j = j - 1
    end
end

function Player:gun_render()

    if items[GUN].collected == true then
        love.graphics.setColor(1, 1, 1, 1)
    
        local i = 1
        for i = 1, self.max_bullets do
            if self.bullet_fired[i] == true then
                love.graphics.setColor(.3, .3, .3, .8)
            else
                love.graphics.setColor(1, 1, 1, .9)
            end
            love.graphics.draw(bullet_images[self.gun_selected], 35 + 25*i, 100)

            
        end
    end
end

