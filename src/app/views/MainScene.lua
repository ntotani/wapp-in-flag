require "cocos.ui.GuiConstants"

local MainScene = class("MainScene", cc.load("mvc").ViewBase)

local teeX, greenX = 15, 325
local MAX_BUMPER = 10
local COIN_APPERE_RATE = 70
local COIN_PER_LOT = 100
local COIN_PER_REWARD = 100
local TIME_OUT_SEC = 5

local DOTS = {
    {name = "shobon", vel = 800, gra = 980, res = 0.5, face = "(´・ω・｀)", dead = "(´・ω...:.;::.."},
    {name = "kita",   vel = 1200, gra = 1980, res = 0.5, face = "(ﾟ∀ﾟ)", dead = "(ﾟ∀...:.;::.."},
    {name = "monyu",  vel = 800, gra = 980, res = 0.5, face = "(*´ω｀*)", dead = "(*´ω...:.;::.."},
    {name = "pokan",  vel = 1200, gra = 1980, res = 0.2, face = "( ﾟдﾟ)", dead = "( ﾟд...:.;::.."},
    {name = "shakin", vel = 1200, gra = 2940, res = 0.5, face = "(｀・ω・´)", dead = "(｀・ω...:.;::.."},
    {name = "pupu",   vel = 800, gra = 980, res = 0.5, face = "(*´艸｀*)", dead = "(*´艸...:.;::.."},
    {name = "tehe",   vel = 800, gra = 980, res = 0.5, face = "(・ω<)", dead = "(・ω...:.;::.."},
    {name = "jito",   vel = 1200, gra = 2940, res = 0.2, face = "(T_T)", dead = "(T_...:.;::.."},
    {name = "he",     vel = 800, gra = 980, res = 0.5, face = "(・へ・)", dead = "(・へ...:.;::.."},
    {name = "mona",   vel = 800, gra = 980, res = 0.5, face = "(´ ∀ ｀)", dead = "(´ ∀ ...:.;::.."},
    {name = "mega",   vel = 800, gra = 980, res = 0.5, face = "(＠_＠)", dead = "(＠_...:.;::.."},
    {name = "yoda",   vel = 800, gra = 980, res = 0.5, face = "(^q^)", dead = "(^q...:.;::.."},
    {name = "nipa",   vel = 400, gra = 490, res = 0.5, face = "(=´▽`=)", dead = "(=´▽...:.;::.."},
    {name = "cry",    vel = 500, gra = 600, res = 0.2, face = "(/ _ ;)", dead = "(/ _ ...:.;::.."},
    {name = "po",     vel = 800, gra = 980, res = 0.5, face = "(*´ｪ`*)", dead = "(*´ｪ...:.;::.."},
    {name = "een",    vel = 500, gra = 600, res = 0.4, face = "(つд⊂)", dead = "(つд...:.;::.."},
    {name = "buwa",   vel = 500, gra = 600, res = 0.6, face = "(´；ω；｀)", dead = "(´；ω...:.;::.."},
    {name = "iiha",   vel = 500, gra = 600, res = 1.0, face = "( ；∀；)", dead = "( ；∀...:.;::.."},
    {name = "nonowa", vel = 800, gra = 980, res = 0.5, face = "(のワの)", dead = "(のワ...:.;::.."},
    {name = "eee",    vel = 400, gra = 490, res = 0.9, face = "(＞Δ＜)", dead = "(＞Δ...:.;::.."},
    {name = "puu",    vel = 800, gra = 980, res = 0.5, face = "(´-ε -｀)", dead = "(´-ε ...:.;::.."},
    {name = "biki",   vel = 1200, gra = 2940, res = 1.0, face = "(＃＾ω＾)", dead = "(＃＾ω...:.;::.."},
    {name = "tira",   vel = 400, gra = 490, res = 1.0, face = "( 'ω')", dead = "( 'ω...:.;::.."},
    {name = "haha",   vel = 800, gra = 980, res = 0.5, face = "(´Д｀)", dead = "(´Д...:.;::.."},
    {name = "foon",   vel = 800, gra = 980, res = 0.5, face = "(´_ゝ`)", dead = "(´_ゝ...:.;::.."},
    {name = "blank",  vel = 800, gra = 980, res = 0.5, face = "@blankblank hi!", dead = "@blankblank hi!"},
    {name = "cyun",   vel = 400, gra = 490, res = 0.7, face = "(・8・)", dead = "(・8...:.;::.."},
    {name = "puyo",   vel = 800, gra = 980, res = 0.5, face = "(◉ ◉)", dead = "(◉ ...:.;::.."},
    {name = "tere",   vel = 800, gra = 980, res = 0.5, face = "(灬ºωº灬)", dead = "(灬ºω...:.;::.."},
    {name = "robo",   vel = 1200, gra = 1980, res = 1.0, face = "(◎皿◎)", dead = "(◎皿...:.;::.."},
    {name = "nyan",   vel = 800, gra = 980, res = 0.5, face = "( Φ ω Φ )", dead = "( Φ ω ...:.;::.."},
    {name = "usa",    vel = 400, gra = 490, res = 0.6, face = "( ･×･)", dead = "( ･×...:.;::.."},
    {name = "manda",  vel = 800, gra = 980, res = 0.5, face = "( ⌒,_ゝ⌒)", dead = "( ⌒,_ゝ...:.;::.."},
    {name = "suya",   vel = 400, gra = 490, res = 0.2, face = "( ˘ω˘ )", dead = "( ˘ω...:.;::.."},
    {name = "pero",   vel = 800, gra = 980, res = 0.5, face = "(´ ڡ `)", dead = "(´ ڡ ...:.;::.."},
    {name = "kona",   vel = 800, gra = 980, res = 0.5, face = "(=ω=)", dead = "(=ω...:.;::.."},
    {name = "yare",   vel = 800, gra = 980, res = 0.5, face = "( ´･_･` )", dead = "( ´･_...:.;::.."},
    {name = "owata",  vel = 800, gra = 980, res = 0.5, face = "＼(^o^)／", dead = "＼(^o^)／"}
}
local DOTS_HASH = {}
for _, e in ipairs(DOTS) do DOTS_HASH[e.name] = e end

function MainScene:onCreate()
    self:initMainNode()
    self:initScores()
    self:initResults()
    self:initDots()
    self:resetDot()
    local cl = cc.EventListenerPhysicsContact:create()
    cl:registerScriptHandler(handler(self, self.onContactBegin), cc.Handler.EVENT_PHYSICS_CONTACT_BEGIN)
    cl:registerScriptHandler(handler(self, self.onContactPresolve), cc.Handler.EVENT_PHYSICS_CONTACT_PRESOLVE)
    cl:registerScriptHandler(handler(self, self.onContactPostsolve), cc.Handler.EVENT_PHYSICS_CONTACT_POSTSOLVE)
    cl:registerScriptHandler(handler(self, self.onContactSeparate), cc.Handler.EVENT_PHYSICS_CONTACT_SEPERATE)
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(cl, self)
    if cc.UserDefault:getInstance():getIntegerForKey("review", 0) == 0 then
        cc.UserDefault:getInstance():setIntegerForKey("review", os.time() + 60 * 60 * 24) -- require review tomorrow
    end
end

function MainScene:initMainNode()
    self.mainNode = display.newNode():addTo(self)
    self.bg = display.newLayer(cc.c3b(0, 153, 255), cc.c3b(255, 255, 255)):addTo(self.mainNode)
    display.newSprite("bg.png"):move(display.center):addTo(self.mainNode)
    self.tee = display.newSprite("grass.png"):addTo(self.mainNode)
    self.green = display.newSprite("grass.png"):addTo(self.mainNode)
    self.green:setPhysicsBody(cc.PhysicsBody:createBox(self.green:getContentSize(), {density = 0.1, restitution = 0.5, friction = 0.5}, cc.p(0, 0)))
    self.green:getPhysicsBody():setDynamic(false)
    self.green:getPhysicsBody():setContactTestBitmask(2)
    self.arrow = display.newSprite("arrow.png"):hide():addTo(self.mainNode)
    self.bumpers = display.newLayer():addTo(self.mainNode)
    self.coins = display.newLayer():addTo(self.mainNode)
    self.pin = display.newSprite("pin.png"):addTo(self.mainNode)
    self.flag = display.newSprite("flag.png"):addTo(self.mainNode)
    self.box = display.newSprite("box.png"):hide():addTo(self.mainNode)
    self.shadows = display.newLayer():addTo(self.mainNode)
    self.face = DOTS[cc.UserDefault:getInstance():getIntegerForKey("lastDot", 1)].name
    -- cc.PHYSICSSHAPE_MATERIAL_DEFAULT = {density = 0.0, restitution = 0.5, friction = 0.5}
    -- cc.PHYSICSBODY_MATERIAL_DEFAULT = {density = 0.1, restitution = 0.5, friction = 0.5}
    self.dot = display.newSprite("dots/" .. self.face .. ".png", 32, 96)
    local material = {density = 0.1, restitution = DOTS_HASH[self.face].res, friction = 0.5}
    local pb = cc.PhysicsBody:createCircle(self.dot:getContentSize().width / 2, material, cc.p(0, 0))
    pb:setGravityEnable(false)
    pb:setContactTestBitmask(1)
    self.dot:setPhysicsBody(pb)
    self.dot:addTo(self.mainNode)
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
end

function MainScene:initScores()
    self.score = cc.Label:createWithSystemFont("0", "Arial", 32):move(display.cx, display.top - 100)
    self.score:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    self.score.value = 0
    self.score:addTo(self.mainNode)
    local coinValue = cc.UserDefault:getInstance():getIntegerForKey("coin", 0)
    self.coin = cc.Label:createWithSystemFont(coinValue, "Arial", 20):align(cc.p(1, 1), display.right - 10, display.top - 24):addTo(self.mainNode)
    self.coin:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    self.coin.value = coinValue
    self.coin.icon = display.newSprite("coin.png"):align(cc.p(1, 1), self.coin:getPositionX() - self.coin:getContentSize().width - 5, self.coin:getPositionY()):addTo(self.mainNode)
    self.feverCount = 0
    if cc.UserDefault:getInstance():getIntegerForKey("fever", -1) == -1 then
        cc.UserDefault:getInstance():setIntegerForKey("fever", os.time() + 60)
    end
    local crown = display.newSprite("crown.png"):align(cc.p(0, 1), 10, display.top - 24):addTo(self.mainNode)
    local highScore = cc.UserDefault:getInstance():getIntegerForKey("score", 0)
    self.highScore = cc.Label:createWithSystemFont(highScore, "Arial", 20):align(cc.p(0, 1), crown:getContentSize().width + 15, display.top - 24):addTo(self.mainNode):enableOutline(cc.c4b(0, 0, 0, 255), 2)
end

function MainScene:initResults()
    self.resultLayer = display.newLayer(cc.c4b(0, 0, 0, 63)):hide():addTo(self)
    self.screenShot = cc.RenderTexture:create(display.width, display.height, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888):move(display.center)
    self.screenShot:retain()
    self.shareMenu = cc.Menu:create(cc.MenuItemImage:create("share_ios.png", "share_ios.png"):align(cc.p(1, 0), display.right - 10, 10):onClicked(function()
        if self.dotsLayer:isVisible() then return end
        local name = cc.FileUtils:getInstance():getWritablePath() .. "screenshot.jpg"
        self.screenShot:newImage():saveToFile(name)
        require("cocos.cocos2d.luaoc").callStaticMethod("AppController", "share", {
            text = DOTS_HASH[self.face][self.shareDead and "dead" or "face"] .. " #OwataGolf http://j.mp/19OfYXw",
            image = name
        })
    end)):move(0, 0):addTo(self):hide()
end

function MainScene:hasDot(idx)
    local dotsFlags = cc.UserDefault:getInstance():getStringForKey("dots", 1)
    for i = 1, idx - 1 do
        dotsFlags = math.floor(dotsFlags / 2)
    end
    return dotsFlags % 2 == 1
end

function MainScene:initDots()
    self.dotsLayer = display.newLayer(cc.c4b(0, 0, 0, 63)):hide():addTo(self)
    local dotsBg = display.newSprite("dots_bg.png"):move(display.center):addTo(self.dotsLayer)
    local bgSize = dotsBg:getContentSize()
    local scrollView = ccui.ScrollView:create():move(display.cx - bgSize.width / 2, display.cy - bgSize.height / 2):addTo(self.dotsLayer)
    scrollView:setBounceEnabled(true)
    scrollView:setDirection(ccui.ScrollViewDir.horizontal)
    scrollView:setTouchEnabled(true)
    scrollView:setContentSize(bgSize)
    scrollView:setInnerContainerSize(cc.size(64 * #DOTS + bgSize.width - 64, bgSize.height))
    for i, e in ipairs(DOTS) do
        display.newSprite("dots/" .. e.name .. ".png", i * 64 - 32 + bgSize.width / 2 - 32, bgSize.height / 2):addTo(scrollView)
    end
    scrollView:getChildren()[1]:setScale(2)
    local currentIdx = function()
        local idx = math.floor((bgSize.width / 2 - scrollView:getInnerContainer():getPositionX() - (bgSize.width / 2 - 32)) / 64) + 1
        return math.max(1, math.min(#DOTS, idx))
    end
    local commitDot = cc.MenuItemImage:create("retry.png", "retry.png"):move(display.cx, display.cy - dotsBg:getContentSize().height / 2):hide()
    local closeDots = function()
        self.dotsLayer:hide()
        commitDot:hide()
        self.bg:onTouch(handler(self, self.onTouch))
    end
    commitDot:onClicked(function()
        local idx = currentIdx()
        self.face = DOTS[idx].name
        self.dot:setTexture("dots/" .. self.face .. ".png")
        self.dot:getPhysicsBody():getFirstShape():setRestitution(DOTS_HASH[self.face].res)
        cc.Director:getInstance():getRunningScene():getPhysicsWorld():setGravity(cc.p(0, -DOTS_HASH[self.face].gra))
        cc.UserDefault:getInstance():setIntegerForKey("lastDot", idx)
        closeDots()
        self:resetDot()
    end)
    scrollView:addTouchEventListener(function(sender, state)
        if state == ccui.TouchEventType.began then
            scrollView:setInertiaScrollEnabled(true)
        elseif state == ccui.TouchEventType.moved then
            commitDot:hide()
        else
            local prevPos = 0
            self.dotsLayer:scheduleUpdate(function()
                local currentPos = scrollView:getInnerContainer():getPositionX()
                if currentPos == prevPos then
                    scrollView:setInertiaScrollEnabled(false)
                    local i = currentIdx()
                    local x = -64 * (i - 1)
                    scrollView:getInnerContainer():setPositionX(x)
                    for _, e in ipairs(scrollView:getChildren()) do e:setScale(1) end
                    scrollView:getChildren()[i]:setScale(2)
                    if self:hasDot(i) then
                        commitDot:show()
                    end
                    self.dotsLayer:unscheduleUpdate()
                end
                prevPos = currentPos
            end)
        end
    end)
    scrollView:addEventListener(function(e, t)
        if t == ccui.ScrollviewEventType.scrolling then
            for _, e in ipairs(scrollView:getChildren()) do e:setScale(1) end
            scrollView:getChildren()[currentIdx()]:setScale(2)
        end
    end)
    self.dotsMenu = cc.Menu:create(commitDot, cc.MenuItemImage:create("dots.png", "dots.png"):align(cc.p(0, 0), display.left + 10, 10):onClicked(function()
        if self.hand then
            self.hand:removeSelf()
            self.hand = nil
        end
        if self.dotsLayer:isVisible() then
            closeDots()
        else
            for i, e in ipairs(scrollView:getChildren()) do
                e:setColor(self:hasDot(i) and cc.c3b(255, 255, 255) or cc.c3b(63, 63, 63))
            end
            self.dotsLayer:show()
            commitDot:show()
            self.bg:removeTouch()
        end
    end)):move(0, 0):addTo(self)
end

function MainScene:showWithScene(transition, time, more)
    self:setVisible(true)
    local scene = display.newScene(self.name_, { physics = true })
    scene:getPhysicsWorld():setGravity(cc.p(0, -DOTS_HASH[self.face].gra))
    scene:addChild(self)
    display.runScene(scene, transition, time, more)
    return self
end

function MainScene:step(delta)
    local rad = self.dot:getContentSize().height / 2
    if self.dot:getPositionY() - rad < 0 then
        self:dead(rad)
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
        local highScore = cc.UserDefault:getInstance():getIntegerForKey("score", 0)
        if self.score.value > highScore then
            highScore = self.score.value
            cc.UserDefault:getInstance():setIntegerForKey("score", highScore)
            self.highScore:setString(highScore)
        end
        if self.score.value % 10 == 0 then
            require("cocos.cocos2d.luaoc").callStaticMethod("AppController", "reportScore", { board = self.face, score = self.score.value })
        end
        self:unscheduleUpdate()
        self.shareDead = false
        self.screenShot:begin()
        self.mainNode:visit()
        self.screenShot:endToLua()
        self.shareMenu:show()
        self:runAction(cc.CallFunc:create(function()
            self:resetDot()
        end))
        if self.physicsContact then
            local d = 0.1
            display.newLayer(cc.c4b(255, 255, 255, 127)):addTo(self):runAction(cc.Sequence:create(
                cc.DelayTime:create(d),
                cc.RemoveSelf:create()
            ))
            self.screenShot:move(display.center):setScale(1)
            self.screenShot:addTo(self.mainNode):runAction(cc.Sequence:create(
                cc.DelayTime:create(d),
                cc.Spawn:create(
                    cc.ScaleTo:create(d, 0),
                    cc.MoveTo:create(d, cc.p(display.right - 10, 10))
                ),
                cc.RemoveSelf:create()
            ))
            audio.playSound("camera.mp3")
        end
        audio.playSound("cupin.mp3")
    end
    for _, e in ipairs(self.coins:getChildren()) do
        if cc.rectIntersectsRect(e:getBoundingBox(), self.dot:getBoundingBox()) then
            self:updateCoin(1)
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
    if self.timeoutCounter ~= -1 then
        self.timeoutCounter = self.timeoutCounter + delta
        if self.timeoutCounter > TIME_OUT_SEC then
            self.timeoutCounter = -1
            self.timeoutMenu = cc.Menu:create(cc.MenuItemImage:create("kill.png", "kill.png"):move(display.cx, display.cy / 2):onClicked(function()
                self:dead(self.dot:getPositionY())
            end)):move(0, 0):addTo(self)
        end
    end
end

function MainScene:dead(y)
    if self.timeoutMenu then
        self.timeoutMenu:removeSelf()
        self.timeoutMenu = nil
    end
    local rad = self.dot:getContentSize().height / 2
    self:unscheduleUpdate()
    local shadows = self.shadows:getChildren()
    for _, e in ipairs(shadows) do e:stopAllActions() end
    if cc.rectIntersectsRect(shadows[#shadows]:getBoundingBox(), self.dot:getBoundingBox()) then
        shadows[#shadows]:removeSelf()
    end
    local die = function() return cc.Spawn:create(cc.FadeTo:create(0.5, 127), cc.MoveBy:create(0.5, cc.p(0, 24))) end
    local x = self.dot:getPositionX()
    if x > display.right then
        local balloon = display.newSprite("balloon.png"):align(cc.p(1, 0), display.right, y):addTo(self.shadows)
        x = display.right - balloon:getContentSize().width / 2 - 8
        y = y + balloon:getContentSize().height / 2 - 24
    elseif x < 0 then
        local balloon = display.newSprite("balloon.png"):addTo(self.shadows)
        balloon:move(balloon:getContentSize().width / 2, balloon:getContentSize().height / 2 + y)
        balloon:setScaleX(-1)
        x = balloon:getContentSize().width / 2 + 8
        y = y + balloon:getContentSize().height / 2 - 24
    end
    display.newSprite("dots/" .. self.face .. ".png", x, y):addTo(self.shadows):runAction(cc.Sequence:create(die(), cc.CallFunc:create(handler(self, self.showResult))))
    self.ring = display.newSprite("ring.png", x, y + rad):addTo(self.mainNode)
    self.ring:runAction(cc.Sequence:create(die()))
    self.shareMenu:show()
    if self.score.value > 0 then
        require("cocos.cocos2d.luaoc").callStaticMethod("AppController", "reportScore", { board = self.face, score = self.score.value })
    end
    audio.playSound("ob.mp3")
end

function MainScene:updateCoin(val)
    self.coin.value = self.coin.value + val
    cc.UserDefault:getInstance():setIntegerForKey("coin", self.coin.value)
    self.coin:setString(self.coin.value)
    self.coin.icon:setPositionX(self.coin:getPositionX() - self.coin:getContentSize().width - 5)
end

function MainScene:showResult()
    self.shareDead = true
    self.screenShot:begin()
    self.mainNode:visit()
    self.screenShot:endToLua()
    local menu = cc.Menu:create(cc.MenuItemImage:create("retry.png", "retry.png"):align(cc.p(0.5, 0), display.cx, 10):onClicked(function()
        for _, e in ipairs(self.resultLayer:getChildren()) do e:removeSelf() end
        self.resultLayer:hide()
        self.score.value = 0
        self.score:setString("0")
        self.ring:removeSelf()
        self.dot:setOpacity(255)
        self:resetDot()
        require("cocos.cocos2d.luaoc").callStaticMethod("AppController", "bannerAd", { show = false })
    end), cc.MenuItemImage:create("board.png", "board.png"):align(cc.p(0, 0), 10, 10):onClicked(function()
        require("cocos.cocos2d.luaoc").callStaticMethod("AppController", "showBoard", { id = self.face })
    end)):move(0, 0)
    if not self:checkLottery() then
        local features = {"none", "share"}
        if cc.UserDefault:getInstance():getIntegerForKey("reward", 0) < os.time() then
            table.insert(features, "reward")
        end
        local reviewState = cc.UserDefault:getInstance():getIntegerForKey("review", 0)
        if reviewState ~= -1 and os.time() > reviewState then
            table.insert(features, "review")
        end
        local feature = features[math.random(1, #features)]
        if feature == "share" then
            self.screenShot:move(display.right - 10, 10):addTo(self.resultLayer):setScale(0)
            self.screenShot:runAction(cc.Spawn:create(cc.ScaleTo:create(0.2, 0.5), cc.MoveTo:create(0.2, display.center)))
        elseif feature == "reward" then
            local dotsBg = display.newSprite("reward.png"):move(display.center):addTo(self.resultLayer)
            local rewardBtn = nil
            rewardBtn = cc.MenuItemImage:create("retry.png", "retry.png"):move(display.cx, display.cy - dotsBg:getContentSize().height / 2):onClicked(function()
                require("cocos.cocos2d.luaoc").callStaticMethod("AppController", "reward", {callback = function(success)
                    if success then
                        self:updateCoin(COIN_PER_REWARD)
                        cc.UserDefault:getInstance():setIntegerForKey("reward", os.time() + 60 * 72) -- AdColony can only 20 in day
                        dotsBg:removeSelf()
                        rewardBtn:removeSelf()
                        if self:checkLottery() then
                            self.resultLayer:hide()
                            require("cocos.cocos2d.luaoc").callStaticMethod("AppController", "bannerAd", { show = false })
                        end
                    end
                end})
            end)
            menu:addChild(rewardBtn)
        elseif feature == "review" then
            local dotsBg = display.newSprite("dots_bg.png"):move(display.center):addTo(self.resultLayer)
            display.newSprite("dots/monyu.png"):move(display.cx, display.cy - 16):addTo(self.resultLayer):setScale(2)
            display.newSprite("star.png"):move(display.cx, display.cy + 32):addTo(self.resultLayer)
            menu:addChild(cc.MenuItemImage:create("retry.png", "retry.png"):move(display.cx, display.cy - dotsBg:getContentSize().height / 2):onClicked(function()
                cc.UserDefault:getInstance():setIntegerForKey("review", -1)
                cc.Application:getInstance():openURL("itms-apps://itunes.apple.com/app/id979813732")
            end))
        end
        self.resultLayer:show()
        require("cocos.cocos2d.luaoc").callStaticMethod("AppController", "bannerAd", { show = true })
    end
    menu:addTo(self.resultLayer)
end

function MainScene:checkLottery()
    if self.coin.value < COIN_PER_LOT then
        return false
    end
    local newDots = {}
    for i = 1, #DOTS do
        if not self:hasDot(i) then
            table.insert(newDots, i)
        end
    end
    if #newDots == 0 then
        return false
    end
    local lottery = display.newLayer(cc.c4b(0, 0, 0, 63)):addTo(self)
    local dotsBg = display.newSprite("dots_bg.png"):move(display.center):addTo(lottery)
    local lot = 1
    local dot = display.newSprite("dots/" .. DOTS[newDots[lot]].name .. ".png"):move(display.center):addTo(lottery)
    dot:setColor(cc.c3b(63, 63, 63))
    dot:setScale(2)
    local effect = display.newSprite("lottery.png"):move(display.center):addTo(lottery)
    effect:setScale(0)
    local commit = nil
    commit = cc.MenuItemImage:create("retry.png", "retry.png"):move(display.cx, display.cy - dotsBg:getContentSize().height / 2):onClicked(function()
        self:updateCoin(-COIN_PER_LOT)
        local dotsFlags = cc.UserDefault:getInstance():getStringForKey("dots", 1)
        dotsFlags = dotsFlags + math.pow(2, newDots[lot] - 1)
        cc.UserDefault:getInstance():setStringForKey("dots", dotsFlags)
        dot:setColor(cc.c3b(255, 255, 255))
        effect:scaleTo({time = 0.1, scale = 1})
        lottery:unscheduleUpdate()
        commit:onClicked(function()
            self.face = DOTS[newDots[lot]].name
            self.dot:setTexture("dots/" .. self.face .. ".png")
            self.dot:getPhysicsBody():getFirstShape():setRestitution(DOTS_HASH[self.face].res)
            cc.Director:getInstance():getRunningScene():getPhysicsWorld():setGravity(cc.p(0, -DOTS_HASH[self.face].gra))
            cc.UserDefault:getInstance():setIntegerForKey("lastDot", newDots[lot])
            lottery:removeSelf()
            self.resultLayer:show()
            require("cocos.cocos2d.luaoc").callStaticMethod("AppController", "bannerAd", { show = true })
        end)
        audio.playSound("lottery.mp3")
    end)
    cc.Menu:create(commit):move(0, 0):addTo(lottery)
    local counter = 0
    lottery:scheduleUpdate(function(dt)
        counter = counter + dt
        if counter > 0.1 then
            counter = 0
            lot = lot + 1
            if lot > #newDots then lot = 1 end
            dot:setTexture("dots/" .. DOTS[newDots[lot]].name .. ".png")
        end
    end)
    audio.playSound("drumroll.mp3")
    return true
end

function MainScene:resetDot()
    local gravity = -DOTS_HASH[self.face].gra
    local dotVel = DOTS_HASH[self.face].vel
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
    local now = os.time()
    local fever = cc.UserDefault:getInstance():getIntegerForKey("fever", now)
    if now > fever then
        self.feverCount = 7
        safeAngle = angle1
        local since = 60 * 60 * 24 -- one day
        cc.UserDefault:getInstance():setIntegerForKey("fever", now + since)
        local body = self.face == "blank" and "OwataGolf" or DOTS_HASH[self.face].face
        require("cocos.cocos2d.luaoc").callStaticMethod("AppController", "localNotification", { sec = since, body = body })
    end
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
        bumperPb:setContactTestBitmask(4)
        bumperPb:setDynamic(false)
        bumper:setPhysicsBody(bumperPb)
    end
    for _, e in ipairs(self.coins:getChildren()) do e:removeSelf() end
    if self.feverCount > 0 then
        self.feverCount = self.feverCount - 1
        local num = 15
        for i = 1, num do
            local t = safeTime / (num + 1) * i
            local x = teeX + safeVel.x * t
            local y = dotY + safeVel.y * t + gravity / 2 * t * t
            display.newSprite("coin.png", x, y):addTo(self.coins)
        end
    elseif self.score.value > 0 and math.random(1, 100) <= COIN_APPERE_RATE then
        local t = 0
        local y = display.top
        while y >= display.top do
            t = safeTime * (0.1 + 0.8 * math.random())
            y = dotY + safeVel.y * t + gravity / 2 * t * t
        end
        local x = teeX + safeVel.x * t
        display.newSprite("coin.png", x, y):addTo(self.coins)
    end
    for _, e in ipairs(self.shadows:getChildren()) do e:removeSelf() end
    if self.score.value == 0 and cc.UserDefault:getInstance():getIntegerForKey("dots", 1) > 1 then
        self.dotsMenu:show()
    end
    self.bg:onTouch(handler(self, self.onTouch))
end

function MainScene:onTouch(event)
    local x, y = event.x, event.y
    local pb = self.dot:getPhysicsBody()
    if event.name == "began" then
        self.beganEvent = event
        return true
    end
    local sub = cc.pSub(self.beganEvent, event)
    local isCancel = cc.pLengthSQ(sub) < 255
    local dir = cc.pNormalize(sub)
    if event.name == "moved" then
        if isCancel then
            self.arrow:hide()
        else
            self.arrow:show()
            local angle = cc.pGetAngle(cc.p(0, 0), dir)
            self.arrow:setRotation(-angle * 180 / math.pi + 90)
            if self.hand then
                self.hand:removeSelf()
                self.hand = nil
            end
        end
    elseif event.name == "ended" and not isCancel then
        pb:setGravityEnable(true)
        pb:setVelocity(cc.pMul(dir, DOTS_HASH[self.face].vel))
        pb:setAngularVelocity(10)
        self.arrow:hide()
        self.dotsMenu:hide()
        self.hit = false
        self.shadowCounter = 0
        self.timeoutCounter = 0
        self.physicsContact = false
        self.bg:removeTouch()
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
    self.physicsContact = true
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
