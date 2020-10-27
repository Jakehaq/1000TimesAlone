Class = require 'class'
require 'Items'
require 'Map'
require 'Player'
require 'Enemy'
require 'Grappling'
require 'Map_Creator'
require 'Final_boss'

--[alright so I'm just going to do my idea brainstorm here
--i'm thinking a game where the dev. was kinda shitty (oh that's me)
--and forgot to organize all the features
--so the player character has to go around and collect all of them so the real game can start
--(the "real" game is just a lame runner or something tho)

--im coming back to this like 12 days later, now that the code is mostly finished
--and wow my idea changed a lot
--my original idea is still good tho, I should try it some other time


WINDOW_HEIGHT = 720
WINDOW_WIDTH = 1080

function love.load()
    

    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {vsync = 1, msaa = 2})
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setTitle("Gamevania")
    largeFont = love.graphics.newFont('font.ttf', 16)
    love.graphics.setFont(largeFont)

    love.audio.setVolume(.05)

    icon = love.image.newImageData("icon.png")
    love.window.setIcon(icon)

    Tiles = {}
    Tiles[-1] = love.graphics.newImage("Setting/Graphics/Save_top1.png")
    Tiles[-2] = love.graphics.newImage("Setting/Graphics/save_bottom1.png")
    Tiles[1] = love.graphics.newImage("Setting/Graphics/New_Stone1.png")
    Tiles[2] = love.graphics.newImage("Setting/Graphics/Column_middle1.png")
    Tiles[3] = love.graphics.newImage("Setting/Graphics/Column_end1.png")
    Tiles[4] = love.graphics.newImage("Setting/Graphics/Column_top1.png")
    Tiles[5] = love.graphics.newImage("Setting/Graphics/Fragile_tile1.png")
    Tiles[6] = love.graphics.newImage("Setting/Graphics/Stone_flavor1.png")
    Tiles[7] = love.graphics.newImage("Setting/Graphics/Stone_alt1.png")
    Tiles[8] = love.graphics.newImage("Setting/Graphics/Stone1.png")

    bullet_images = {}
    bullet_images[1] = love.graphics.newImage("Player/bullet1.png")
    bullet_images[2] = love.graphics.newImage("Powerups/Graphics/Shotgun_bullet1.png")
    bullet_images[3] = love.graphics.newImage("Powerups/Graphics/Rocket1.png")
    bullet_images[4] = love.graphics.newImage("Powerups/Graphics/Freeze_bullet1.png")
    bullet_images[5] = love.graphics.newImage("Enemies/Enemy_shoot1.png")

    player = Player()
    player:init(294, 524, 2, 3)

    Final_boss = Final_boss()
    Final_boss:init(500, 300, 8, 2)

    grapple = Grappling()
    grapple:init()

    sound_effects = {}
    sound_effects['jump'] = love.audio.newSource('Powerups/Sounds/jump.wav', 'static')
    sound_effects['shoot'] = love.audio.newSource('Powerups/Sounds/gun.wav', 'static')
    sound_effects['wall hit'] = love.audio.newSource('Powerups/Sounds/wall_hit.wav', 'static')
    sound_effects['powerup'] = love.audio.newSource('Powerups/Sounds/powerup.wav', 'static')
    sound_effects['Enemy Hit'] = love.audio.newSource('Enemies/enemy_hit.wav', 'static')
    sound_effects['Enemy Death'] = love.audio.newSource('Enemies/kill.wav', 'static')
    sound_effects['Hurt'] = love.audio.newSource('Player/hurt.wav', 'static')
    sound_effects['Menu'] = love.audio.newSource('Setting/Music/menu.wav', 'static')
    sound_effects['Wall Break'] = love.audio.newSource('Setting/Music/wallbreak.wav', 'static')
    sound_effects['Dash'] = love.audio.newSource('Powerups/Sounds/dash.wav', 'static')
    sound_effects['Shotgun'] = love.audio.newSource('Powerups/Sounds/shotgun_shoot.wav', 'static')
    sound_effects['Rocket'] = love.audio.newSource('Powerups/Sounds/rocket_shoot.wav', 'static')
    sound_effects['Freeze'] = love.audio.newSource('Powerups/Sounds/freeze_shoot.wav', 'static')
    sound_effects['Enemy Shoot'] = love.audio.newSource('Enemies/shoot.wav', 'static')
    sound_effects['Health Upgrade'] = love.audio.newSource('Powerups/Sounds/health_upgrade.wav', 'static')
    sound_effects['Save'] = love.audio.newSource('Setting/Music/sav.wav', 'static')
    sound_effects['Health Get'] = love.audio.newSource('Setting/Music/health_get.wav', 'static')
    sound_effects['Boss death'] = love.audio.newSource('Setting/Music/boss_death.wav', 'static')
    sound_effects['Boss hit'] = love.audio.newSource('Setting/Music/boss_hit.wav', 'static')
    sound_effects['Crouch'] = love.audio.newSource('Player/fall.wav', 'static')


    icons = {}
    icons[1] = love.graphics.newImage("Powerups/Graphics/boots1.png")
    icons[2] = love.graphics.newImage("Powerups/Graphics/Jetpack1.png")
    icons['Health Pack'] = player.heart
    icons['Ammo Upgrade'] = love.graphics.newImage("Powerups/Graphics/Ammo_upgrade1.png")
    icons['Jump Upgrade'] = love.graphics.newImage("Powerups/Graphics/jetpack_upgrade1.png")

    Map_create = Map_Creator()

    Map_create:init()

    Enemy_load()
    local i = 1
    local j = 1
    for i = 1, #enemies do
        if enemies[i].map_x == player.map_x and enemies[i].map_y == player.map_y then
            enemies_in_room[j] = enemies[i]
            j = j + 1
        end
    end

    music = {}
    music['Danger'] = love.audio.newSource('Setting/Music/ambient_boss.wav', 'stream')
    music['Ambient'] = love.audio.newSource('Setting/Music/game_ambient.wav', 'stream')
    music['End'] = love.audio.newSource('Setting/Music/game_adventure.wav', 'stream')
    
    cutscene = false
    final_image = love.graphics.newImage("Player/Idle/end_screen1.png")
    timer_end = -1
    noise = false

    minimap = false
end

function Enemy_load()
    enemies[1] = Enemy()
    enemies[1]:init(720, 288, 2, 3, 1, (22/14))
    enemies[2] = Enemy()
    enemies[2]:init(500, 400, 2, 4, 2, 0)
    enemies[3] = Enemy()
    enemies[3]:init(700, 200, 2, 4, 4, 0)
    enemies[4] = Enemy()
    enemies[4]:init(360, 288, 1, 4, 1, 22/14)
    enemies[5] = Enemy()
    enemies[5]:init(360, 288, 1, 3, 2, 0)
    enemies[6] = Enemy()
    enemies[6]:init(144, 144, 1, 2, 2, 0)
    enemies[7] = Enemy()
    enemies[7]:init(720 - 144, 144, 2, 2, 4, 0)
    enemies[8] = Enemy()
    enemies[8]:init(288, 288, 3, 3, 1, 22/14)
    enemies[9] = Enemy()
    enemies[9]:init(360, 360, 3, 3, 2, 22/14)
    enemies[10] = Enemy()
    enemies[10]:init(288, 288, 3, 5, 2, 44/14)
    enemies[11] = Enemy()
    enemies[11]:init(360, 144 + 72, 3, 5, 1, 0)
    enemies[12] = Enemy()
    enemies[12]:init(400, 350, 2, 6, 1, 22/14)
    enemies[13] = Enemy()
    enemies[13]:init(720, 200, 2, 5, 4, 0)
    enemies[14] = Enemy()
    enemies[14]:init(600, 144, 1, 5, 1, 22/14)
    enemies[15] = Enemy()
    enemies[15]:init(480, 244, 1, 6, 2, 44/14)
    enemies[16] = Enemy()
    enemies[16]:init(720, 288, 1, 6, 2, 0)
    enemies[17] = Enemy()
    enemies[17]:init(360, 144, 3, 3, 2, 0)
    enemies[18] = Enemy()
    enemies[18]:init(540, 144, 2, 7, 3, -22/14)
    enemies[19] = Enemy()
    enemies[19]:init(720, 144, 3, 7, 1, 22/14)
    enemies[20] = Enemy()
    enemies[20]:init(288, 360, 3, 8, 4, 0)
    enemies[21] = Enemy()
    enemies[21]:init(480, 480, 3, 9, 2, 0)
    enemies[22] = Enemy()
    enemies[22]:init(360, 288 - 72 , 2, 9, 4, 0)
    enemies[23] = Enemy()
    enemies[23]:init(720 - 144, 144, 2, 9, 1, 22/14)
    enemies[24] = Enemy()
    enemies[24]:init(720, 288, 2, 8, 4, 0)
    enemies[25] = Enemy()
    enemies[25]:init(360, 288 - 72, 4, 7, 4, 0)
    enemies[26] = Enemy()
    enemies[26]:init(720, 288 - 72, 4, 7, 4, 0)
    enemies[27] = Enemy()
    enemies[27]:init(540, 360, 5, 7, 2, 22/14)
    enemies[28] = Enemy()
    enemies[28]:init(720, 360, 6, 7, 2, 22/14)
    enemies[29] = Enemy()
    enemies[29]:init(720 - 72*3, 360, 7, 8, 2, -44/14)
    enemies[30] = Enemy()
    enemies[30]:init(720 - 72 - 36, 144, 4, 6, 1, 22/14)
    enemies[31] = Enemy()
    enemies[31]:init(200, 360, 4, 5, 1, 0)
    enemies[32] = Enemy()
    enemies[32]:init(360, 540, 5, 4, 4, 0)
    enemies[33] = Enemy()
    enemies[33]:init(540, 360, 5, 3, 3, 0)
    enemies[34] = Enemy()
    enemies[34]:init(360, 480, 5, 2, 4, 0)
    enemies[35] = Enemy()
    enemies[35]:init(540, 288, 5, 2, 3, 0)
    enemies[36] = Enemy()
    enemies[36]:init(720, 144 + 72, 5, 1, 2, -22/7)
    enemies[37] = Enemy()
    enemies[37]:init(540, 360 + 72 - 36, 4, 1, 1, 0)
    enemies[38] = Enemy()
    enemies[38]:init(540, 360 -36 , 3, 1, 2, -22/7)
    enemies[39] = Enemy()
    enemies[39]:init(720, 288, 3, 2, 3, 0)
    enemies[40] = Enemy()
    enemies[40]:init(540, 360, 2, 1, 3, 0)
    enemies[41] = Enemy()
    enemies[41]:init(360, 144, 1, 1, 4, 0)
end

function Final_cutscene(dt)
    timer_end = timer_end - dt

    if timer_end > 0 then
        player.dX = 0
        player.animation_number = 1
        player.frame_number = 1
        player.rotation = 0
    end

    if player.map_x == 9 and player.map_y == 3 and player.room_x >= 420 and cutscene == false and timer_end < 0 then
        
        cutscene = true
        timer_end = 1.5

    end


    if cutscene == true and timer_end < 0 then
        if noise == false then
            love.audio.play(sound_effects['Crouch'])
            noise = true
            player.room_y = player.room_y + player.player_height/2
            player.player_height = player.player_height/2
        end

        
        player.frame_number = 1
        player.animation_number = 6

        if timer_end < -1 then
            player.dX = 100
            player.rotation = player.rotation + dt* (22/7)
        end
        player.dY = 0
        player.frame_number = 1
        player.animation_number = 6
        

    end

    if cutscene == true and player.room_x > 900 then
        player.dX = 0
        player.room_x = 900
        show_credits = true
        love.audio.stop(music['Danger'])
        love.audio.play(music['End'])
    end
end

function love.keypressed(key)
    if key == 'escape' and minimap == false then
        love.event.quit()
    end

    if explain == false and player.timer['Dashing'] <= 0 then
        if key == 'w' and cutscene == false then
            player:jump(key)
        end
        
    end

    if key == 'a' and player.timer['Dash'] >= 0 and player.timer['Dashing'] <= 0 and player.left_dash == true and cutscene == false then
        player.dX = -500
        player.timer['Dashing'] = .25
        player.dashed = true
        love.audio.stop(sound_effects['Dash'])
        love.audio.play(sound_effects['Dash'])
    end

    if key == 'd' and player.timer['Dash'] >= 0 and player.timer['Dashing'] <= 0 and player.right_dash == true and cutscene == false then
        player.dX = 500
        player.timer['Dashing'] = .25
        player.dashed = true
        love.audio.stop(sound_effects['Dash'])
        love.audio.play(sound_effects['Dash'])
    end

    if key == 'space' and explain == false then
        local i = 0
        repeat
            player.gun_selected = player.gun_selected%4
            player.gun_selected = player.gun_selected + 1
            i = i + 1
        until (items[player.guns[player.gun_selected]].collected == true or i == 4)
        player.arm_frame = 1
    end

    if (key == 'space') and explain == true then
        local i = 1
        for i = 1, #items do
            if items[i].collected == true and items[i].explained == false then
                items[i].explained = true
            end
        end
        explain = false
        love.audio.play(sound_effects['Menu'])
    end

    if key == 's' then
        player:save()
    end

    if key == 'q' and minimap == false then
        minimap = true
    elseif key == 'q' then
        minimap = false
    end

end

function love.mousepressed(x, y, button, istouch)
    if button == 1 and cutscene == false then
        left_clicked = true
    end

    if button == 2 then
        if items[4].collected == true and player.in_air == true then
            grapple:throw()
        end
    elseif grapple.state == "Travel" then
        grapple.state = "Retract"
    end



end

function music_change()
    if player.map_x == Final_boss.map_x and player.map_y == Final_boss.map_y and Final_boss.health > 0 then
        love.audio.stop(music['Ambient'])
        love.audio.play(music['Danger'])
    end
end

function love.update(dt)

    music_change()

    player.timer['Hurt'] = player.timer['Hurt'] - dt

    if explain == false then
        player:controls(dt)
        player:Change_Map()
    end

    local j = 1
    for j = 1, #enemies_in_room do
        if enemies_in_room[j].state ~= "Freeze" and explain == false then
            enemies_in_room[j]:move_collide(dt)
            enemies_in_room[j]:animation(dt)
        end
        if explain == false then
            enemies_in_room[j]:defrost(dt)
        end
    end

    if items[4].collected == true then
        if grapple.state == "Throw" then
            grapple:travel_hit(dt)
        end

        if grapple.state == "Hit" then
            grapple:swing(dt)
        end
    end

    if explain == false then
        player:animation(dt)
    end

    if player.map_x == Final_boss.map_x and player.map_y == Final_boss.map_y and Final_boss.health > 0 then
        Final_boss:artificial_intelligence(dt)
        Final_boss:controls(dt)

        Final_boss:animation(dt)
    end

    local i = 1
    local j = 1
    for i = 1, #maps do
        for j = 1, #maps[i] do
            if player.map_x == j and player.map_y == i then
                maps_explored[i][j] = true
            end
        end
    end

    player:death_check()
    
    Final_cutscene(dt)
end

function love.draw()
    love.audio.play(music['Ambient'])

    love.graphics.clear(0, 0, 0, 1)

    maps[player.map_y][player.map_x]:render()

    love.graphics.setColor(1, 1, 1, 1)

    local i = 1
    for i = 1, #items do
        if items[i].map_x == player.map_x and items[i].map_y == player.map_y and items[i].collected == false then
            items[i]:render()
            player:item_collect(i)
        end
    end

    
    
    local i = 1
    for i = 1, player.max_bullets do
        if player.bullet_fired[i] == true then
            player.bullets[i]:render()
        end
    end

    

    local j = 0
    for j = 1, #enemies_in_room do
        enemies_in_room[j]:render()
    end

    if items[4].collected == true then
        grapple:gun_render()
        if grapple.state == "Throw" or grapple.state == "Hit" then
            grapple:render()
        end
    end
    
    
    player:render()



    player:gun_render()
    player:health_render()

    if player.map_x == Final_boss.map_x and player.map_y == Final_boss.map_y and Final_boss.health > 0 then
        Final_boss:render()
    end

    if player.timer['Hurt'] > 2.94 and player.timer['Hurt'] < 3 then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle('fill', 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)
    end


    local i = 1
    for i = 1, #items do
        if items[i].collected == true and items[i].explained == false and explain == true then
            items[i]:explain()
        end
    end

    if minimap == true then
        love.graphics.clear(0, 0, .1, 1)
        local i = 1
        local j = 1
        local offsetY = 0
        for i = 1, #maps do
            local offsetX = 0
            
            for j = 1, #maps[i] do
                if maps_explored[i][j] == true then
                    local k = 1
                    local l = 1
                    for k = 1, #maps[i][j].layout do
                        for l = 1, #maps[i][j].layout[k] do
                            if maps[i][j].layout[k][l] ~= 0 then
                                if maps[i][j].layout[k][l] < 0 then
                                    love.graphics.setColor(.8, .1, .1, 1)
                                else
                                    love.graphics.setColor(.1, .1, .5, 1)
                                end
                                love.graphics.rectangle('fill', 120*(j-1) + 8*(l-1) - offsetX, 80*(i-1) + 8*(k-1) - offsetY, 8, 8)
                            end
                        end
                        if i == player.map_y and j == player.map_x then
                            love.graphics.setColor(.7, .2, .7, 1)
                            love.graphics.rectangle('fill', 120*(player.map_x-1) + 8*(math.floor(player.room_x/X_SCALE)) - offsetX,80*(player.map_y-1) + 8*(math.floor(player.room_y/Y_SCALE)) - offsetY, 8, 16)
                        end
                    end
                end
                offsetX = 8 + offsetX
                
            end
            offsetY = offsetY + 8
        end

        

    end

    if show_credits == true then
        love.graphics.clear(0, 0, 0, 1)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf("Good job! You saved the world! As a reward for your hard work, here's the protagonist in a swimsuit", 200, 100, 360, 'center', 0, 2)
        love.graphics.draw(final_image, 480, 300)
        love.graphics.print("Credits-- Everything: Jakehaq", 200, 600, 0 ,2)

        love.graphics.print("if reference_understood == false then", 200, 640)
        love.graphics.print("search(metroid ending, google)", 220, 660)
    end

end