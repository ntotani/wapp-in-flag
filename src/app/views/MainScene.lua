
local MainScene = class("MainScene", cc.load("mvc").ViewBase)

local teeX, greenX = 15, 325

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

    -- cc.PHYSICSSHAPE_MATERIAL_DEFAULT = {density = 0.0, restitution = 0.5, friction = 0.5}
    -- cc.PHYSICSBODY_MATERIAL_DEFAULT = {density = 0.1, restitution = 0.5, friction = 0.5}
    self.dot = display.newSprite("ball.png", 32, 96)
    local material = {density = 0.1, restitution = 0.5, friction = 0.5}
    local pb = cc.PhysicsBody:createCircle(self.dot:getContentSize().width / 2, material, cc.p(0, 0))
    pb:setGravityEnable(false)
    pb:setContactTestBitmask(1)
    self.dot:setPhysicsBody(pb)
    self.dot:addTo(self.mainNode)

    self.flag = display.newSprite("flag.png", 900, 600):addTo(self.mainNode)
    self.box = display.newSprite("box.png", 900, 500):addTo(self.mainNode)
    self:resetDot()

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
    self.screenShot = cc.RenderTexture:create(360, 640, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888):move(display.center)
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
    elseif cc.rectIntersectsRect(self.dot:getBoundingBox(), self.flag:getBoundingBox()) and not self.hit then
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
            display.newSprite("ball.png"):move(self.dot:getPosition()):rotate(self.dot:getRotation()):addTo(self.shadows):runAction(cc.Sequence:create(cc.FadeOut:create(2), cc.RemoveSelf:create()))
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
    local dotY = math.random(100, 500)
    local pb = self.dot:getPhysicsBody()
    pb:setVelocity(cc.p(0, 0))
    pb:setAngularVelocity(0)
    pb:setGravityEnable(false)
    self.dot:move(teeX, dotY)
    self.dot:setRotation(0)
    self.arrow:move(teeX, dotY)
    self.tee:move(teeX, dotY - (self.dot:getContentSize().height + self.tee:getContentSize().height) / 2)
    local boxY = math.random(100, 500)
    self.box:move(greenX, boxY)
    self.flag:move(greenX, boxY + 30)
    self.green:move(greenX, boxY - (self.box:getContentSize().height + self.green:getContentSize().height) / 2)
    for _, e in ipairs(self.bumpers:getChildren()) do e:removeSelf() end
    for i = 1, math.random(1, 5) do
        local bumper = display.newSprite("bumper.png", math.random(80, 280), math.random(220, 420)):addTo(self.bumpers)
        local bumperPb = cc.PhysicsBody:createCircle(bumper:getContentSize().width / 2, cc.PHYSICSBODY_MATERIAL_DEFAULT, cc.p(0, 0))
        bumperPb:setDynamic(false)
        bumper:setPhysicsBody(bumperPb)
    end
    for _, e in ipairs(self.coins:getChildren()) do e:removeSelf() end
    display.newSprite("coin.png", 180, 500):addTo(self.coins)
    for _, e in ipairs(self.shadows:getChildren()) do e:removeSelf() end
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
        pb:setVelocity(cc.pMul(dir, 800))
        pb:setAngularVelocity(10)
        self.arrow:hide()
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

return MainScene
