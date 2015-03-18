
local MainScene = class("MainScene", cc.load("mvc").ViewBase)

local teeX, greenX = 15, 325

function MainScene:onCreate()
    self.bg = display.newLayer(cc.c3b(0, 153, 255), cc.c3b(255, 255, 255)):onTouch(handler(self, self.onTouch)):addTo(self)
    display.newSprite("bg.png"):move(display.center):addTo(self)

    self.tee = display.newSprite("grass.png"):addTo(self)
    self.green = display.newSprite("grass.png"):addTo(self)
    self.green:setPhysicsBody(cc.PhysicsBody:createBox(self.green:getContentSize(), {density = 0.1, restitution = 0.5, friction = 0.5}, cc.p(0, 0)))
    self.green:getPhysicsBody():setDynamic(false)
    self.arrow = display.newSprite("arrow.png"):hide():addTo(self)
    self.shadows = display.newLayer():addTo(self)

    -- cc.PHYSICSSHAPE_MATERIAL_DEFAULT = {density = 0.0, restitution = 0.5, friction = 0.5}
    -- cc.PHYSICSBODY_MATERIAL_DEFAULT = {density = 0.1, restitution = 0.5, friction = 0.5}
    self.dot = display.newSprite("ball.png", 32, 96)
    local material = {density = 0.1, restitution = 0.5, friction = 0.5}
    local pb = cc.PhysicsBody:createCircle(self.dot:getContentSize().width / 2, material, cc.p(0, 0))
    pb:setGravityEnable(false)
    pb:setContactTestBitmask(1)
    self.dot:setPhysicsBody(pb)
    self.dot:addTo(self)

    self.flag = display.newSprite("flag.png", 900, 600):addTo(self)
    self.box = display.newSprite("box.png", 900, 500):addTo(self)
    self:resetDot()

    self.score = cc.Label:createWithSystemFont("0", "Arial", 32):move(display.cx, display.top - 100)
    self.score:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    self.score.value = 0
    self.score:addTo(self)

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
        self.ring = display.newSprite("ring.png", self.dot:getPositionX(), self.dot:getPositionY() + rad):addTo(self)
        self.dot:runAction(cc.Sequence:create(die(), cc.CallFunc:create(handler(self, self.showResult))))
        self.ring:runAction(cc.Sequence:create(die()))
        local shadows = self.shadows:getChildren()
        for _, e in ipairs(shadows) do e:stopAllActions() end
        if cc.rectIntersectsRect(shadows[#shadows]:getBoundingBox(), self.dot:getBoundingBox()) then
            shadows[#shadows]:removeSelf()
        end
        self.bg:removeTouch()
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
        self:resetDot()
        audio.playSound("cupin.mp3")
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
    local screenShot = cc.RenderTexture:create(360, 640, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
    screenShot:begin()
    self:visit()
    screenShot:endToLua()
    local resultLayer = display.newLayer(cc.c4b(0, 0, 0, 63)):addTo(self)
    screenShot:move(display.center):addTo(resultLayer):setScale(0.5)
    local share = cc.MenuItemImage:create("share_ios.png", "share_ios.png"):move(display.cx, display.cy - 180):onClicked(function()
        local name = cc.FileUtils:getInstance():getWritablePath() .. "screenshot.jpg"
        screenShot:newImage():saveToFile(name)
        require("cocos.cocos2d.luaoc").callStaticMethod("AppController", "share", {
            text = "SCORE: " .. self.score.value,
            image = name
        })
    end)
    local retry = cc.MenuItemImage:create("retry.png", "retry.png"):move(display.cx, 45):onClicked(function()
        resultLayer:removeSelf()
        self.score.value = 0
        self.score:setString("0")
        self.ring:removeSelf()
        self.dot:setOpacity(255)
        self:resetDot()
        self.bg:onTouch(handler(self, self.onTouch))
    end)
    cc.Menu:create(share, retry):move(0, 0):addTo(resultLayer)
end

function MainScene:resetDot()
    local dotY = math.random(100, 500)
    local pb = self.dot:getPhysicsBody()
    pb:setVelocity(cc.p(0, 0))
    pb:setAngularVelocity(0)
    pb:setGravityEnable(false)
    self.dot:move(teeX, dotY)
    self.arrow:move(teeX, dotY)
    self.tee:move(teeX, dotY - (self.dot:getContentSize().height + self.tee:getContentSize().height) / 2)
    local boxY = math.random(100, 500)
    self.box:move(greenX, boxY)
    self.flag:move(greenX, boxY + 30)
    self.green:move(greenX, boxY - (self.box:getContentSize().height + self.green:getContentSize().height) / 2)
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
