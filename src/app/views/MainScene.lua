require "cocos.ui.GuiConstants"

local MainScene = class("MainScene", cc.load("mvc").ViewBase)

local teeX, greenX = 15, 325
local MAX_BUMPER = 10
local COIN_APPERE_RATE = 10

local DOTS = {
    shobon = {vel = 800, gra = 980},
    shakin = {vel = 1600, gra = 1960}
}

function MainScene:onCreate()
    self.mainNode = display.newNode():addTo(self)
    self.bg = display.newLayer(cc.c3b(0, 153, 255), cc.c3b(255, 255, 255)):onTouch(handler(self, self.onTouch)):addTo(self.mainNode)
    display.newSprite("bg.png"):move(display.center):addTo(self.mainNode)

    self.tee = display.newSprite("grass.png"):addTo(self.mainNode)
    self.green = display.newSprite("grass.png"):addTo(self.mainNode)
    self.green:setPhysicsBody(cc.PhysicsBody:createBox(self.green:getContentSize(), {density = 0.1, restitution = 0.5, friction = 0.5}, cc.p(0, 0)))
    self.green:getPhysicsBody():setDynamic(false)
    self.arrow = display.newSprite("arrow.png"):hide():addTo(self.mainNode)
    self.bumpers = display.newLayer():addTo(self.mainNode)
    self.coins = display.newLayer():addTo(self.mainNode)
    self.shadows = display.newLayer():addTo(self.mainNode)

    self.face = "shobon"

    -- cc.PHYSICSSHAPE_MATERIAL_DEFAULT = {density = 0.0, restitution = 0.5, friction = 0.5}
    -- cc.PHYSICSBODY_MATERIAL_DEFAULT = {density = 0.1, restitution = 0.5, friction = 0.5}
    self.dot = display.newSprite("dots/" .. self.face .. ".png", 32, 96)
    local material = {density = 0.1, restitution = 0.5, friction = 0.5}
    local pb = cc.PhysicsBody:createCircle(self.dot:getContentSize().width / 2, material, cc.p(0, 0))
    pb:setGravityEnable(false)
    pb:setContactTestBitmask(1)
    self.dot:setPhysicsBody(pb)
    self.dot:addTo(self.mainNode)

    self.pin = display.newSprite("pin.png"):addTo(self.mainNode)
    self.flag = display.newSprite("flag.png"):addTo(self.mainNode)
    self.box = display.newSprite("box.png"):hide():addTo(self.mainNode)

    self.score = cc.Label:createWithSystemFont("0", "Arial", 32):move(display.cx, display.top - 100)
    self.score:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    self.score.value = 0
    self.score:addTo(self.mainNode)

    local coinValue = cc.UserDefault:getInstance():getIntegerForKey("coin", 0)
    self.coin = cc.Label:createWithSystemFont(coinValue, "Arial", 20):align(cc.p(1, 1), display.right - 10, display.top - 10):addTo(self.mainNode)
    self.coin:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    self.coin.value = coinValue
    self.coin.icon = display.newSprite("coin.png"):align(cc.p(1, 1), self.coin:getPositionX() - self.coin:getContentSize().width - 5, self.coin:getPositionY()):addTo(self.mainNode)

    self.resultLayer = display.newLayer(cc.c4b(0, 0, 0, 63)):hide():addTo(self)
    self.screenShot = cc.RenderTexture:create(display.width, display.height, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888):move(display.center)
    self.screenShot:setScale(0.5)
    self.screenShot:retain()
    self.shareMenu = cc.Menu:create(cc.MenuItemImage:create("share_ios.png", "share_ios.png"):align(cc.p(1, 0), display.right - 10, 10):onClicked(function()
        local name = cc.FileUtils:getInstance():getWritablePath() .. "screenshot.jpg"
        self.screenShot:newImage():saveToFile(name)
        require("cocos.cocos2d.luaoc").callStaticMethod("AppController", "share", {
            text = "SCORE: " .. self.score.value,
            image = name
        })
    end)):move(0, 0):addTo(self):hide()
    local dotsLayer = display.newLayer(cc.c4b(0, 0, 0, 63)):hide():addTo(self)
    local dotsBg = display.newSprite("dots_bg.png"):move(display.center):addTo(dotsLayer)
    local bgSize = dotsBg:getContentSize()
    local scrollView = ccui.ScrollView:create():move(display.cx - bgSize.width / 2, display.cy - bgSize.height / 2):addTo(dotsLayer)
    scrollView:setBounceEnabled(true)
    scrollView:setDirection(ccui.ScrollViewDir.horizontal)
    scrollView:setTouchEnabled(true)
    scrollView:setContentSize(bgSize)
    scrollView:setInnerContainerSize(cc.size(64 * 10 + bgSize.width - 64, bgSize.height))
    for i = 1, 10 do
        display.newSprite("dots/" .. (i % 2 == 0 and "shobon" or "shakin") .. ".png", i * 64 - 32 + bgSize.width / 2 - 32, bgSize.height / 2):addTo(scrollView)
    end
    scrollView:getChildren()[1]:setScale(2)
    local currentIdx = function()
        return math.floor((bgSize.width / 2 - scrollView:getInnerContainer():getPositionX() - (bgSize.width / 2 - 32)) / 64) + 1
    end
    local commitDot = cc.MenuItemImage:create("retry.png", "retry.png"):move(display.cx, display.cy - dotsBg:getContentSize().height / 2):hide():onClicked(function()
        print("commit")
    end)
    scrollView:addTouchEventListener(function(sender, state)
        if state == ccui.TouchEventType.began then
            scrollView:setInertiaScrollEnabled(true)
        elseif state == ccui.TouchEventType.moved then
            commitDot:hide()
        else
            local prevPos = 0
            dotsLayer:scheduleUpdate(function()
                local currentPos = scrollView:getInnerContainer():getPositionX()
                if currentPos == prevPos then
                    scrollView:setInertiaScrollEnabled(false)
                    local i = currentIdx() - 1
                    local x = -i * 64
                    scrollView:getInnerContainer():setPositionX(x)
                    for _, e in ipairs(scrollView:getChildren()) do e:setScale(1) end
                    scrollView:getChildren()[i + 1]:setScale(2)
                    commitDot:show()
                    dotsLayer:unscheduleUpdate()
                end
                prevPos = currentPos
            end)
        end
    end)
    scrollView:addEventListener(function(e, t)
        if t == ccui.ScrollviewEventType.scrolling then
            for _, e in ipairs(scrollView:getChildren()) do e:setScale(1) end
            local i = currentIdx()
            local dots = scrollView:getChildren()
            i = math.max(math.min(i, #dots), 1)
            dots[i]:setScale(2)
        end
    end)
    self.dotsMenu = cc.Menu:create(commitDot, cc.MenuItemImage:create("dots.png", "dots.png"):align(cc.p(0, 0), display.left + 10, 10):onClicked(function()
        if self.hand then
            self.hand:removeSelf()
            self.hand = nil
        end
        if dotsLayer:isVisible() then
            dotsLayer:hide()
            commitDot:hide()
            self.bg:onTouch(handler(self, self.onTouch))
        else
            dotsLayer:show()
            commitDot:show()
            self.bg:removeTouch()
        end
    end)):move(0, 0):addTo(self)

    local handPos = cc.p(display.cx + 50, display.cy + 50 - 100)
    self.hand = display.newSprite("hand.png"):move(handPos):addTo(self)
    self.hand:runAction(cc.RepeatForever:create(cc.Sequence:create(
        cc.DelayTime:create(0.5),
        cc.MoveBy:create(0.5, cc.p(-100, -100)),
        cc.DelayTime:create(0.5),
        cc.CallFunc:create(function() self.hand:setVisible(false) end),
        cc.DelayTime:create(0.5),
        cc.CallFunc:create(function() self.hand:move(handPos):setVisible(true) end)
    )))

    self:resetDot()

    local cl = cc.EventListenerPhysicsContact:create()
    cl:registerScriptHandler(handler(self, self.onContactBegin), cc.Handler.EVENT_PHYSICS_CONTACT_BEGIN)
    cl:registerScriptHandler(handler(self, self.onContactPresolve), cc.Handler.EVENT_PHYSICS_CONTACT_PRESOLVE)
    cl:registerScriptHandler(handler(self, self.onContactPostsolve), cc.Handler.EVENT_PHYSICS_CONTACT_POSTSOLVE)
    cl:registerScriptHandler(handler(self, self.onContactSeparate), cc.Handler.EVENT_PHYSICS_CONTACT_SEPERATE)
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(cl, self)
end

function MainScene:showWithScene(transition, time, more)
    self:setVisible(true)
    local scene = display.newScene(self.name_, { physics = true })
    scene:getPhysicsWorld():setGravity(cc.p(0, -980))
    scene:addChild(self)
    display.runScene(scene, transition, time, more)
    return self
end

function MainScene:step(delta)
    local rad = self.dot:getContentSize().height / 2
    if self.dot:getPositionY() - rad < 0 then
        self:unscheduleUpdate()
        self.dot:setPositionY(rad)
        self.dot:setRotation(0)
        local pb = self.dot:getPhysicsBody()
        pb:setVelocity(cc.p(0, 0))
        pb:setAngularVelocity(0)
        pb:setGravityEnable(false)
        local die = function() return cc.Spawn:create(cc.FadeTo:create(0.5, 127), cc.MoveBy:create(0.5, cc.p(0, 10))) end
        self.ring = display.newSprite("ring.png", self.dot:getPositionX(), self.dot:getPositionY() + rad):addTo(self.mainNode)
        self.dot:runAction(cc.Sequence:create(die(), cc.CallFunc:create(handler(self, self.showResult))))
        self.ring:runAction(cc.Sequence:create(die()))
        local shadows = self.shadows:getChildren()
        for _, e in ipairs(shadows) do e:stopAllActions() end
        if cc.rectIntersectsRect(shadows[#shadows]:getBoundingBox(), self.dot:getBoundingBox()) then
            shadows[#shadows]:removeSelf()
        end
        self.bg:removeTouch()
        self.shareMenu:show()
        audio.playSound("ob.mp3")
        return
    elseif cc.pDistanceSQ(cc.p(self.dot:getPosition()), cc.p(self.flag:getPosition())) <= 4 * rad * rad and not self.hit then
        self.hit = true
        self.dot:setPosition(self.flag:getPosition())
        self.dot:getPhysicsBody():setVelocity(cc.p(0, 0))
        self.dot:getPhysicsBody():setGravityEnable(false)
        audio.playSound("flag.m4a")
        self.dot:setVisible(false)
        self.dot:runAction(cc.Sequence:create({
            cc.DelayTime:create(0.5),
            cc.Show:create(),
            cc.CallFunc:create(function()
                self.dot:getPhysicsBody():setGravityEnable(true)
            end)
        }))
    elseif cc.rectIntersectsRect(self.dot:getBoundingBox(), self.box:getBoundingBox()) then
        self.score.value = self.score.value + 1
        self.score:setString(self.score.value)
        self:unscheduleUpdate()
        self.screenShot:begin()
        self.mainNode:visit()
        self.screenShot:endToLua()
        self.shareMenu:show()
        self:runAction(cc.CallFunc:create(function()
            self:resetDot()
        end))
        audio.playSound("cupin.mp3")
    end
    for _, e in ipairs(self.coins:getChildren()) do
        local dist = cc.pDistanceSQ(cc.p(e:getPosition()), cc.p(self.dot:getPosition()))
        local limit = rad + e:getContentSize().width / 2
        if dist <= limit * limit then
            self.coin.value = self.coin.value + 1
            cc.UserDefault:getInstance():setIntegerForKey("coin", self.coin.value)
            self.coin:setString(self.coin.value)
            self.coin.icon:setPositionX(self.coin:getPositionX() - self.coin:getContentSize().width - 5)
            e:removeSelf()
            audio.playSound("coin.mp3")
        end
    end
    if not self.hit then
        self.shadowCounter = self.shadowCounter + delta
        if self.shadowCounter >= 0.1 then
            self.shadowCounter = 0
            display.newSprite("dots/" .. self.face .. ".png"):move(self.dot:getPosition()):rotate(self.dot:getRotation()):addTo(self.shadows):runAction(cc.Sequence:create(cc.FadeOut:create(2), cc.RemoveSelf:create()))
        end
    end
end

function MainScene:showResult()
    self.screenShot:begin()
    self.mainNode:visit()
    self.screenShot:endToLua()
    self.screenShot:addTo(self.resultLayer)
    local retry = cc.MenuItemImage:create("retry.png", "retry.png"):move(display.cx, 45):onClicked(function()
        for _, e in ipairs(self.resultLayer:getChildren()) do e:removeSelf() end
        self.resultLayer:hide()
        self.score.value = 0
        self.score:setString("0")
        self.ring:removeSelf()
        self.dot:setOpacity(255)
        self:resetDot()
        self.bg:onTouch(handler(self, self.onTouch))
    end)
    cc.Menu:create(retry):move(0, 0):addTo(self.resultLayer)
    self.resultLayer:show()
end

function MainScene:resetDot()

    local faces = table.keys(DOTS)
    self.face = faces[math.random(1, #faces)]
    self.dot:setTexture("dots/" .. self.face .. ".png")
    local pw = cc.Director:getInstance():getRunningScene():getPhysicsWorld()
    if pw then pw:setGravity(cc.p(0, -DOTS[self.face].gra)) end

    local gravity = -DOTS[self.face].gra
    local dotVel = DOTS[self.face].vel
    local angle1, angle2, dotY, flagY = -1, -1, 0, 0
    while angle1 == -1 or angle2 == -1 do
        dotY = math.random(100, display.top - 100)
        flagY = math.random(100, display.top - 100)
        angle1, angle2 = self:calcTheta(greenX - teeX, flagY - dotY, gravity, dotVel)
    end
    local pb = self.dot:getPhysicsBody()
    pb:setVelocity(cc.p(0, 0))
    pb:setAngularVelocity(0)
    pb:setGravityEnable(false)
    self.dot:move(teeX, dotY)
    self.dot:setRotation(0)
    self.arrow:move(teeX, dotY)
    self.tee:move(teeX, dotY - (self.dot:getContentSize().height + self.tee:getContentSize().height) / 2)
    self.flag:move(greenX, flagY)
    self.pin:move(greenX, flagY - (self.flag:getContentSize().height + self.pin:getContentSize().height) / 2)
    self.box:move(greenX, self.pin:getPositionY() - self.pin:getContentSize().height / 2)
    self.green:move(greenX, self.box:getPositionY() - self.green:getContentSize().height / 2)
    local safeAngle = math.random(1, 2) == 1 and angle1 or angle2
    local safeVel = cc.pMul(cc.pForAngle(safeAngle), dotVel)
    local safeTime = (greenX - teeX) / safeVel.x
    local safePath = self:calcPath(safeVel.x, safeVel.y, gravity, safeTime, self.dot:getContentSize().width, teeX, dotY)
    for _, e in ipairs(self.bumpers:getChildren()) do e:removeSelf() end
    for _ = 1, math.random(0, math.min(self.score.value, MAX_BUMPER)) do
        local bumper = display.newSprite("bumper.png"):addTo(self.bumpers)
        local s = bumper:getContentSize()
        local x, y = -1, -1
        while x == -1 or y == -1 do
            x = math.random(display.left, display.right)
            y = math.random(display.bottom, display.top)
            local rect = cc.rect(x - s.width / 2, y - s.height / 2, s.width, s.height)
            if cc.rectIntersectsRect(rect, self.tee:getBoundingBox()) or cc.rectIntersectsRect(rect, self.green:getBoundingBox()) then
                x, y = -1, -1
            else
                for _, e in ipairs(safePath) do
                    if cc.rectIntersectsRect(e, rect) then
                        x, y = -1, -1
                        break
                    end
                end
            end
        end
        bumper:move(x, y)
        local bumperPb = cc.PhysicsBody:createCircle(bumper:getContentSize().width / 2, cc.PHYSICSBODY_MATERIAL_DEFAULT, cc.p(0, 0))
        bumperPb:setDynamic(false)
        bumper:setPhysicsBody(bumperPb)
    end
    for _, e in ipairs(self.coins:getChildren()) do e:removeSelf() end
    if math.random(1, 100) <= COIN_APPERE_RATE then
        local t = safeTime * (0.1 + 0.8 * math.random())
        local x = teeX + safeVel.x * t
        local y = dotY + safeVel.y * t + gravity / 2 * t * t
        if y < display.top then
            display.newSprite("coin.png", x, y):addTo(self.coins)
        end
    end
    for _, e in ipairs(self.shadows:getChildren()) do e:removeSelf() end
    if self.score.value == 0 then
        self.dotsMenu:show()
    end
end

function MainScene:onTouch(event)
    local x, y = event.x, event.y
    local pb = self.dot:getPhysicsBody()
    if event.name == "began" then
        self.beganEvent = event
        return true
    end
    local dir = cc.pNormalize(cc.pSub(self.beganEvent, event))
    if event.name == "moved" then
        local angle = cc.pGetAngle(cc.p(0, 0), dir)
        self.arrow:setRotation(-angle * 180 / math.pi + 90)
        self.arrow:show()
        if self.hand then
            self.hand:removeSelf()
            self.hand = nil
        end
    elseif event.name == "ended" then
        pb:setGravityEnable(true)
        pb:setVelocity(cc.pMul(dir, DOTS[self.face].vel))
        pb:setAngularVelocity(10)
        self.arrow:hide()
        self.dotsMenu:hide()
        self.hit = false
        self.shadowCounter = 0
        self:scheduleUpdate(handler(self, self.step))
        audio.playSound("shot.mp3")
    end
end

function MainScene:onContactBegin(contact)
    return true
end

function MainScene:onContactPresolve(contact, solve)
    return true
end

function MainScene:onContactPostsolve(contact, solve)
end

function MainScene:onContactSeparate(contact)
end

function MainScene:calcTheta(x, y, g, v)
    local A = g * x * x / (2 * v * v)
    local a = x / A
    local b = -y / A + 1
    local X = a * a / 4 - b
    if X <= 0 then
        return -1, -1
    end
    X = math.sqrt(X)
    local X1 = X - a / 2
    local X2 = -X - a / 2
    return math.atan(X1), math.atan(X2)
end

function MainScene:calcPath(vx, vy, acc, maxTime, dist, bx, by)
    local currentTime = 0
    local pos = function(t)
        return cc.p(vx * t, vy * t + (acc / 2) * t * t)
    end
    local rects = {}
    while currentTime <= maxTime do
        local p = pos(currentTime)
        local dt = 0.1
        while cc.pDistanceSQ(p, pos(currentTime + dt)) > dist * dist do
            dt = dt / 2
        end
        local np = pos(currentTime + dt)
        table.insert(rects, cc.rectUnion(
            cc.rect(bx +  p.x - dist / 2, by +  p.y - dist / 2, dist, dist),
            cc.rect(bx + np.x - dist / 2, by + np.y - dist / 2, dist, dist)
        ))
        currentTime = currentTime + dt
    end
    return rects
end

function MainScene:dumpPath(path)
    for _, e in ipairs(path) do
        local box = display.newSprite("box.png", e.x + e.width / 2, e.y + e.height / 2):addTo(self)
        box:setScale(e.width, e.height)
        box:setOpacity(127)
    end
end

return MainScene
