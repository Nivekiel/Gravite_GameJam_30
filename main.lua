-- Cette ligne permet d'afficher des traces dans la console pendant l'éxécution
io.stdout:setvbuf('no')

-- Empèche Love de filtrer les contours des images quand elles sont redimentionnées
-- Indispensable pour du pixel art
love.graphics.setDefaultFilter("nearest")

math.randomseed(love.timer.getTime())

local ship = {}
ship.x = 0
ship.y = 0
ship.angle = 270
ship.vx = 0
ship.vy = 0
ship.speed = 4
ship.engineOn = false
ship.img = love.graphics.newImage("images/ship.png")
ship.imgEngine = love.graphics.newImage("images/engine.png")

local platform = {}
platform.x = 0
platform.y = 0
platform.largeur = 100
platform.hauteur = 40

local sea = {}
sea.x = 0
sea.y = 0
sea.largeur = 0
sea.hauteur = 10

local sndEngine = love.audio.newSource("sons/engine.ogg", "static")
local sndExplod = love.audio.newSource("sons/explod.ogg", "static")

local dead = false
local victoire = false
local timerDead = 0

function DemarreJeu()
    
    victoire = false
    dead = false
    ship.x = largeur_ecran / 2
    ship.y = hauteur_ecran - 200
    ship.angle = 270
    ship.vx = 0
    ship.vy = 0

end

function love.load()

    love.window.setTitle("Gravité - Game Jam #30")

    love.graphics.setBackgroundColor(0, 0.5, 1)
    largeur_ecran = love.graphics.getWidth()
    hauteur_ecran = love.graphics.getHeight()

    fontDraw = love.graphics.newFont("fonts/ZenDots.ttf", 10)
    Font = love.graphics.newFont("fonts/Minecraft.ttf", 50)

    ship.ox = ship.img:getWidth() / 2
    ship.oy = ship.img:getHeight() / 2
    
    ship.oex = ship.imgEngine:getWidth() / 2
    ship.oey = ship.imgEngine:getHeight() / 2

    platform.x = 150
    platform.y = hauteur_ecran - (platform.hauteur / 2)

    sea.largeur = largeur_ecran
    sea.x = largeur_ecran / 2 - sea.largeur / 2
    sea.y = hauteur_ecran - sea.hauteur

    DemarreJeu()
  
end

function love.update(dt)

    -- Déplacement du vaisseau
    if love.keyboard.isDown("d", "right") then
        ship.angle = ship.angle + (90 * dt)
        if ship.angle > 360 then ship.angle = 360 end
    end
    if love.keyboard.isDown("q", "left") then
        ship.angle = ship.angle - (90 * dt)
        if ship.angle < 180 then ship.angle = 180 end
    end
    if love.keyboard.isDown("z", "up") then
        ship.engineOn = true
        sndEngine:play()

        local angle_rad = math.rad(ship.angle)
        local force_x = math.cos(angle_rad) * (ship.speed * dt)
        local force_y = math.sin(angle_rad) * (ship.speed * dt)
        ship.vx = ship.vx + force_x
        ship.vy = ship.vy + force_y
    else
        ship.engineOn = false
        sndEngine:stop()
    end

    -- Vélocité / gravité
    ship.vy = ship.vy + (0.6 * dt)

    -- Appli de la vélocité X & Y
    ship.x = ship.x + ship.vx
    ship.y = ship.y + ship.vy

    -- Limitation écran
    if ship.y - ship.oy * 2 <= 0 then -- haut
        ship.y = 0 + (ship.oy * 2)
        ship.vy = 0
    end
    if ship.x >= largeur_ecran then -- droite
        ship.x = largeur_ecran
        ship.vx = 0
    end
    if ship.y + ship.oy / 2 >= hauteur_ecran then -- bas
        -- Perdu
        sndExplod:play()
        dead = true
        timerDead = 10
    end
    if ship.x <= 0 then -- gauche
        ship.x = 0
        ship.vx = 0
    end
    
    if dead == true then
        ship.y = hauteur_ecran - ship.oy
        sndEngine:stop()
        timerDead = timerDead - 1
        if timerDead == 0 then
            DemarreJeu()
        end
    end

    -- Vaisseau se pose sur la platform
    local coliPlatform = platform.y - (platform.hauteur / 2) - ship.oy
    if ship.y > coliPlatform then
        local distX = math.abs(platform.x - ship.x)
        if distX < platform.largeur / 2 then
            if ship.angle >= 250 and ship.angle <= 280 and ship.vy <= 1 and ship.vx <= 1 then
                -- Gagné
                ship.vy = 0
                ship.x = platform.x + (platform.largeur / 2) - 50
                ship.y = platform.y - (platform.hauteur / 2) - 6
                ship.angle = 270
                sndEngine:stop()
                victoire = true
            else
                -- Perdu
                sndExplod:play()
                dead = true
                timerDead = 10
            end
        end
    end
    
end

function love.draw()

    -- Dessin vaisseau et moteur
    if dead == false then
        love.graphics.draw(ship.img, ship.x, ship.y, math.rad(ship.angle), 2, 2, ship.ox, ship.oy)
    
        if ship.engineOn == true then
            love.graphics.draw(ship.imgEngine, ship.x, ship.y, math.rad(ship.angle), 2, 2, ship.oex, ship.oey)
        end        
    end

    -- Dessin platform
    love.graphics.rectangle("fill", platform.x - (platform.largeur / 2), platform.y - (platform.hauteur / 2), platform.largeur, platform.hauteur)

    -- Dessin océan
    love.graphics.setColor(0, 0.3, 0.6)
    love.graphics.rectangle("fill", sea.x, sea.y, sea.largeur, sea.hauteur)
    love.graphics.setColor(1, 1, 1)

    -- Message victoire
    if victoire == true then
        love.graphics.setFont(Font)
        love.graphics.print("You win !!!", largeur_ecran / 2 - 110, hauteur_ecran / 2 - 100)
        love.graphics.setFont(fontDraw)
        love.graphics.print("Appuyer sur 'n' pour relancer une nouvelle partie !", largeur_ecran / 2 - 150, hauteur_ecran / 2 - 50)
    end

    -- Debug
    -- love.graphics.setFont(fontDraw)
    -- love.graphics.print("Angle : "..tostring(math.floor(ship.angle)), 1, 1)
    -- love.graphics.print("Vitesse Y : "..tostring(math.floor(ship.vy)), 1, 20)
    -- love.graphics.print("Vitesse X : "..tostring(math.floor(ship.vx)), 1, 40)
    -- love.graphics.print("Position Y : "..tostring(math.floor(ship.y)), 1, 60)
    -- love.graphics.print("Position X : "..tostring(math.floor(ship.x)), 1, 80)
    -- love.graphics.print("Timer : "..tostring(math.floor(timerDead)), 1, 100)
    
end

function love.keypressed(key)
  
  print(key)

  if key == "escape" then
    love.event.quit()
  end

  if key == "n" and victoire == true then
      DemarreJeu()
  end
  
end
  