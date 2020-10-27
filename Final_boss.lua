Final_boss = Class{}
require 'Bullets'

RUN_ACCEL = 1300

RUN_SPEED = 430
JUMP_SPEED = 470
GRAVITY = 700
RUN_FRICTION = 5
WINDOW_WIDTH = 1080
WINDOW_HEIGHT = 720
MAP_HEIGHT = 10
MAP_WIDTH = 15

RUN_FRAME_TIME = .06

X_SCALE = WINDOW_WIDTH/MAP_WIDTH
Y_SCALE = WINDOW_HEIGHT/MAP_HEIGHT

function Final_boss:init(room_x, room_y, map_x, map_y)
    self.room_x = room_x
    self.room_y = room_y

    self.map_x = map_x
    self.map_y = map_y

    self.dY = 0
    self.dX = 0

    self.player_width = 60
    self.player_height = 124

    self.sprites = {{}, {}, {}, {}, {}}
    self.arm_sprites = {{}, {}, {}, {}}
    self.animation_number = 1
    self.frame_number = 1
    self.X_SCALE = 1
    self.arm_frame = 0
    self.previous_animation = 1
    
    self.sprites[1][1] = love.graphics.newImage("Boss/Graphics/Walk/Final_area_boss_walk1.png")

    self.sprites[2][1] = love.graphics.newImage("Boss/Graphics/Walk/Final_area_boss_walk3.png")
    self.sprites[2][2] = love.graphics.newImage("Boss/Graphics/Walk/Final_area_boss_walk2.png")
    self.sprites[2][3] = love.graphics.newImage("Boss/Graphics/Walk/Final_area_boss_walk3.png")
    self.sprites[2][4] = love.graphics.newImage("Boss/Graphics/Walk/Final_area_boss_walk4.png")
    self.sprites[2][5] = love.graphics.newImage("Boss/Graphics/Walk/Final_area_boss_walk5.png")
    self.sprites[2][6] = love.graphics.newImage("Boss/Graphics/Walk/Final_area_boss_walk6.png")
    self.sprites[2][7] = love.graphics.newImage("Boss/Graphics/Walk/Final_area_boss_walk5.png")
    self.sprites[2][8] = love.graphics.newImage("Boss/Graphics/Walk/Final_area_boss_walk4.png")

    self.sprites[3][1] = love.graphics.newImage("Boss/Graphics/Jump/New_Player_jump1.png")
    self.sprites[3][2] = love.graphics.newImage("Boss/Graphics/Jump/New_Player_jump2.png")
    self.sprites[3][3] = love.graphics.newImage("Boss/Graphics/Jump/New_Player_jump3.png")

    self.sprites[4][1] = love.graphics.newImage("Boss/Graphics/Shoot/Final_boss_shoot2.png")
    self.sprites[4][2] = love.graphics.newImage("Boss/Graphics/Shoot/Final_boss_shoot1.png")
    self.sprites[4][3] = love.graphics.newImage("Boss/Graphics/Shoot/Final_boss_shoot2.png")
    self.sprites[4][4] = love.graphics.newImage("Boss/Graphics/Shoot/Final_boss_shoot3.png")
    self.sprites[4][5] = love.graphics.newImage("Boss/Graphics/Shoot/Final_boss_shoot4.png")
    self.sprites[4][6] = love.graphics.newImage("Boss/Graphics/Shoot/Final_boss_shoot5.png")
    self.sprites[4][7] = love.graphics.newImage("Boss/Graphics/Shoot/Final_boss_shoot4.png")
    self.sprites[4][8] = love.graphics.newImage("Boss/Graphics/Shoot/Final_boss_shoot3.png")
    self.sprites[5][3] = love.graphics.newImage("Boss/Graphics/Shoot/Final_boss_jump_shoot1.png")
    
    self.arm_sprites[1][1] = love.graphics.newImage("Boss/Graphics/Shoot/Final_boss_arm1.png")
    self.arm_sprites[1][2] = love.graphics.newImage("Boss/Graphics/Shoot/Final_boss_arm2.png")
    

    self.health_packs = 15
    self.health = self.health_packs

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
    self.timer['To shoot'] = 0
    self.in_air = false
    self.angle = 0

    self.max_bullets = 100
    self.bullets = {}
    self.bullet_fired = {}
    self.gun_selected = 1
    self.shooting = false

    local i = 1
    for i = 50, 1500 do
        self.bullets[i] = Bullets()
        self.bullet_fired[i] = false
    end

    self.decision_move = "Idle"
    self.decision_shoot = "Wait"
    self.decision_jump = "Idle"
    

    

end

function Final_boss:artificial_intelligence(dt)
    local distanceX = (player.player_width/2 + player.room_x) - (self.player_width/2 + self.room_x)
    local distanceY = (player.player_height/2 + player.room_y) - (self.player_height/2 + self.room_y)
    local distance = (distanceX*distanceX + distanceY*distanceY)^.5

    if distanceX < 0 then
        angle = math.atan(distanceY/distanceX) + PI
        
    else
        angle = math.atan(distanceY/distanceX)
    end

    local locationX = self.player_width/2 + self.room_x
    local locationY = self.player_height/2 + self.room_y
    self.hit = true

    repeat
        locationX = locationX + math.cos(angle)*30
        locationY = locationY + math.sin(angle)*30
        if maps[self.map_y][self.map_x].layout[math.ceil(locationY/Y_SCALE)][math.ceil(locationX/X_SCALE)] ~= 0 or locationX > WINDOW_WIDTH-90 then
            self.hit = false
            break
        end
    until (locationX > player.room_x and locationX < player.room_x + player.player_width and locationY > player.room_y and locationY < player.player_height + player.room_y)




    if math.abs(distanceX) > 350 then
        if distanceX > 0 then
            self.decision_move = "Right"
        elseif distanceX < 0 then
            self.decision_move = "Left"
        end
    elseif math.abs(distanceX) > 150 then
        if distanceX > 0 and self.hit == false then
            self.decision_move = "Right"
        elseif distanceX < 0 and self.hit == false then
            self.decision_move = "Left"
        end
    elseif math.abs(distanceX) < 50 or self.hit == false then
        if distanceX > 0 and self.room_x > 150 then
            self.decision_move = "Left"
        elseif distanceX < 0 and self.room_x < WINDOW_WIDTH - 150 then
            self.decision_move = "Right"
        end
    else
        self.decision_move = "Idle"
    end

    if self.room_x < 100 then
        self.decision_move = "Right"
    elseif self.room_x > WINDOW_WIDTH - 100 then
        self.decision_move = "Left"
    end

    if math.abs(player.dX) < 10 and distanceY > 100 and self.hit == false then
        if distanceX > 0 then
            self.decision_move = "Left"
        else
            self.decision_move = "Right"
        end
    end

    if self.decision_move == "Idle" then
        if distanceX < 0 then
            self.X_SCALE = 1
        else
            self.X_SCALE = -1
        end
    end



    local block_left_down = maps[self.map_y][self.map_x].layout[math.ceil( ((self.room_y + self.player_height*(2/3)) / (Y_SCALE)))][math.ceil((self.room_x - self.player_width*.2)/ X_SCALE)]
    local block_right_down = maps[self.map_y][self.map_x].layout[math.ceil(((self.room_y + self.player_height*(2/3)) / (Y_SCALE)))][math.ceil((self.room_x + self.player_width*1.2) / X_SCALE)]
    local block_left_mid = maps[self.map_y][self.map_x].layout[math.ceil(((self.room_y + self.player_height*(1/3)) / (Y_SCALE)))][math.ceil((self.room_x - self.player_width*.2) / X_SCALE)]
    local block_right_mid = maps[self.map_y][self.map_x].layout[math.ceil(((self.room_y + self.player_height*(1/3)) / (Y_SCALE)))][math.ceil((self.room_x + self.player_width*1.2) / X_SCALE)]
    local block_left_up = maps[self.map_y][self.map_x].layout[math.ceil(((self.room_y - self.player_height*(1/3)) / (Y_SCALE)))][math.ceil((self.room_x - self.player_width*.2) / X_SCALE)]
    local block_right_up = maps[self.map_y][self.map_x].layout[math.ceil(((self.room_y - self.player_height*(1/3)) / (Y_SCALE)))][math.ceil((self.room_x + self.player_width*1.2) / X_SCALE)]
    local block_up = maps[self.map_y][self.map_x].layout[math.ceil(((self.room_y - self.player_height*(1/3)) / (Y_SCALE)))][math.ceil(self.room_x / X_SCALE)]

    if self.jumped == false then
        if self.decision_move ==  "Right" then
            if block_right_down ~= 0 or block_right_mid ~= 0 then
                self.decision_jump = "Jump"
            end
        elseif self.decision_move == "Left" then
            if block_left_down ~= 0 or block_left_mid ~= 0 then
                self.decision_jump = "Jump"
            end
        end
        if distanceY < -100 and block_up == 0 then
            self.decision_jump = "Jump"
        end

        if player.timer['Shooting'] >= 0.1 and player.timer['Shooting'] < .15 and block_up == 0 then
            self.decision_jump = "Jump"
        end

    elseif self.decision_move ~= "Idle" and self.decision_jump == "Idle" and self.in_air == true and self.double_jumped == false then
        if self.dY > 10 then
            if self.decision_move ==  "Right" then
                if block_right_down ~= 0 or block_right_mid ~= 0 then
                    self.decision_jump = "Jump"
                end
            elseif self.decision_move == "Left" then
                if block_left_down ~= 0 or block_left_mid ~= 0 then
                    self.decision_jump = "Jump"
                end
            end
        end
        if player.timer['Shooting'] >= 0.1 and player.timer['Shooting'] < .15 and block_up == 0 then
            self.decision_jump = "Jump"
        end
    end



end

function Final_boss:map_collision(x_shift, y_shift)
    local collision_Xscale = X_SCALE
    local collision_Yscale = Y_SCALE
    if maps[self.map_y][self.map_x].layout[math.ceil((self.room_y + y_shift) / (collision_Yscale))][math.ceil(self.room_x / collision_Xscale)] == 0 then

        if maps[self.map_y][self.map_x].layout[math.ceil((self.room_y + y_shift) / (collision_Yscale))][math.ceil((self.room_x+self.player_width) / (collision_Xscale))] == 0 then

            local movement = false
            while math.abs(y_shift) > .1 and movement == false do
                if maps[self.map_y][self.map_x].layout[math.ceil((self.room_y + y_shift + self.player_height) / (collision_Yscale))][math.ceil((self.room_x + self.player_width) / (collision_Xscale))] == 0 then

                    if maps[self.map_y][self.map_x].layout[math.ceil((self.room_y + y_shift + self.player_height) / (collision_Yscale))][math.ceil(self.room_x / (collision_Xscale))] == 0 then
                        self.room_y = self.room_y + y_shift
                        movement = true
                        self.in_air = true
                        
                    else
                        self.dY = 0
                        self.double_jumped = false
                        self.jumped = false
                        self.timer[DOUBLE_JUMP] = 0
                        self.dashed = false
                        self.in_air = false
                        y_shift = y_shift/2
                    end
                
                else
                    self.dY = 0
                    y_shift = y_shift/2
                    self.double_jumped = false
                    self.jumped = false
                    self.timer[DOUBLE_JUMP] = 0
                    self.dashed = false
                    self.in_air = false
                    
                end
            end
        else
            self.dY = -.1
        end
    else
        self.dY = -.1
    end

    if maps[self.map_y][self.map_x].layout[math.ceil(self.room_y/collision_Yscale)][math.ceil((self.room_x + x_shift)/collision_Xscale)] == 0 then

        if maps[self.map_y][self.map_x].layout[math.ceil(self.room_y/collision_Yscale)][math.ceil((self.room_x + self.player_width + x_shift)/collision_Xscale)] == 0 then

            if maps[self.map_y][self.map_x].layout[math.ceil((self.room_y+self.player_height)/collision_Yscale)][math.ceil((self.room_x + self.player_width + x_shift)/collision_Xscale)] == 0 then

                if maps[self.map_y][self.map_x].layout[math.ceil((self.room_y+self.player_height)/collision_Yscale)][math.ceil((self.room_x + x_shift)/collision_Xscale)] == 0 then

                    if maps[self.map_y][self.map_x].layout[math.ceil((self.room_y+self.player_height/2)/collision_Yscale)][math.ceil((self.room_x + self.player_width + x_shift)/collision_Xscale)] == 0 then

                        if maps[self.map_y][self.map_x].layout[math.ceil((self.room_y+self.player_height/2)/collision_Yscale)][math.ceil((self.room_x + x_shift)/collision_Xscale)] == 0 then
        
                            self.room_x = self.room_x + x_shift
                        else
                            self.dX = self.dX/5
                        end
                    else
                        self.dX = self.dX/5
                    end
                else
                    self.dX = self.dX/5
                end
            else
                self.dX = self.dX/5
            end
        else
            self.dX = self.dX/5
        end
    else
        self.dX = self.dX/5
    end
        
    
end

function Final_boss:jump()
    if self.decision_jump == "Jump" then
        if self.jumped == false then
            love.audio.stop(sound_effects['jump'])
            love.audio.play(sound_effects['jump'])
            self.dY = -JUMP_SPEED
            self.jumped = true
            self.double_jumped = false
            self.decision_jump = "Idle"
        elseif self.jumped == true and self.double_jumped == false then
            love.audio.stop(sound_effects['jump'])
            love.audio.play(sound_effects['jump'])
            self.dY = -JUMP_SPEED
            self.double_jumped = true
            self.replay_jump_anim = true
            self.decision_jump = "Idle"
        end
    end
end

function Final_boss:Shoot(dt)
    local i = 1
    for i = 50, self.max_bullets + 1450 do
        if self.bullet_fired[i] == true then
            self.bullets[i]:wall_collision(dt)
        end
    end
    self.timer['To shoot'] = self.timer['To shoot'] - dt


    if self.timer['Shooting'] <= 0 and self.timer['To shoot'] <= 0 and self.hit == true then
        local i = 1
        
        
            while self.bullet_fired[i + 50] == true and i <= 1450 do
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
                self.bullets[i + 50]:init(self.room_x + x_offset, self.room_y + y_offset, self.map_x, self.map_y, i + 50, 0, "Enemy", player.room_x + player.player_width/2, player.room_y + player.player_height/2)
                love.audio.stop(sound_effects['shoot'])
                love.audio.play(sound_effects['shoot'])
                self.bullet_fired[i + 50] = true
                self.shooting = true
                self.timer['To shoot'] = .4
                self.bullets[i + 50]:fire(0, 0)
                self.angle = self.bullets[i + 50].angle
            end
    end
end

function Final_boss:controls(dt)
    self.timer['Dashing'] = self.timer['Dashing'] - dt
    self.timer['Dash'] = self.timer['Dash'] - dt

    if self.decision_move == "Left" then
        self.dX = -RUN_ACCEL*dt + self.dX
        if self.dashed == false then
            self.timer['Dash'] = .1
            self.right_dash = false
            self.left_dash = true
        end
    end

    if self.timer['Dashing'] <= 0 and self.dX < 0 then
        self.dX = math.max(self.dX, -RUN_SPEED)
    end

    if self.decision_move == "Right" then
        self.dX = RUN_ACCEL*dt + self.dX
        if self.dashed == false then
            self.timer['Dash'] = .1
            self.right_dash = true
            self.left_dash = false
        end
    end

    self:jump()

    if self.timer['Dashing'] <= 0 and self.dX > 0 then
        self.dX = math.min(self.dX, RUN_SPEED)
    end


    self.dY = self.dY + GRAVITY*dt

    if math.abs(self.dX) < 10 then
        self.dX = 0
    end

    if self.timer['Dashing'] <= 0 then
        self.dX = self.dX * (1-(RUN_FRICTION*dt))
    end

    local y_shift = self.dY*dt
    local x_shift = self.dX*dt

    self:map_collision(x_shift, y_shift)

    self:Shoot(dt)

end

function Final_boss:animation(dt)
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
            self.timer['Animation'] = RUN_FRAME_TIME
            self.arm_frame = 1
            self.timer['Shooting'] = .24
            self.shooting = false
        elseif self.in_air == true then
            self.animation_number = 5
            self.frame_number = 3
            self.timer['Animation'] = RUN_FRAME_TIME
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
        self.timer['Animation'] = RUN_FRAME_TIME
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

function Final_boss:render()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.sprites[self.animation_number][self.frame_number], math.floor(self.room_x + self.player_width/2), math.floor(self.room_y - 2), 0, self.X_SCALE, 1, self.player_width/2)
    if (self.animation_number == 4) and self.X_SCALE == 1 then
        love.graphics.draw(self.arm_sprites[self.gun_selected][self.arm_frame], math.floor(self.room_x + self.player_width-24), math.floor(self.room_y + 66), self.angle - PI, 1, 1, 26, 0)
    elseif (self.animation_number == 4) and self.X_SCALE == -1 then
        love.graphics.draw(self.arm_sprites[self.gun_selected][self.arm_frame], math.floor(self.room_x + self.player_width-36), math.floor(self.room_y + 66), self.angle, self.X_SCALE, 1, 26, 0)
    elseif(self.animation_number == 5) and self.X_SCALE == 1 then
        love.graphics.draw(self.arm_sprites[self.gun_selected][self.arm_frame], math.floor(self.room_x + self.player_width-34), math.floor(self.room_y + 66), self.angle - PI, 1, 1, 26, 0)
    elseif (self.animation_number == 5) and self.X_SCALE == -1 then
        love.graphics.draw(self.arm_sprites[self.gun_selected][self.arm_frame], math.floor(self.room_x + self.player_width-26), math.floor(self.room_y + 66), self.angle, self.X_SCALE, 1, 26, 0)
    end
    local i = 1
    for i = 1, #self.bullets do
        if self.bullet_fired[i] == true then
            self.bullets[i]:render()
        end
    end
end