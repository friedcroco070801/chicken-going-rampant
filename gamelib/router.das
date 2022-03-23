require daslib/media
require pentwin/scene
require pentwin/node
require pentwin/sprite
require pentwin/utils
require pentwin/application
require level
require constant
require userdata
require pentwin/button
require pentwin/soundpool
require info
require credits

module router public

class RouterScene: Scene
    def drawBackground(): void
        var backdrop: Sprite? = new Sprite(BACKDROP)
        addChild(backdrop)

        var cloud1: Sprite? = new Sprite(CLOUD, float4(0.0f, 0.0f, 240.0f, 180.0f))
        var animation1: Animation? = new Animation()
        var interval1: float = 0.85f + 0.6f * randFloat01()
        for i in range(0, 3)
            animation1->addFrame(new AnimFrame(CLOUD, interval1, float4(240.0f * float(i), 0.0f, 240.0f, 180.0f)))
        cloud1->addAction(new RepeatForever(animation1))
        cloud1->setAnchor(0.5f, 0.5f)
        cloud1->setPosition(160.0f, 240.0f)
        cloud1->setScale(interval1, interval1)
        addChild(cloud1)

        var cloud2: Sprite? = new Sprite(CLOUD, float4(0.0f, 0.0f, 240.0f, 180.0f))
        var animation2: Animation? = new Animation()
        var interval2: float = 0.85f + 0.6f * randFloat01()
        for i in range(0, 3)
            animation2->addFrame(new AnimFrame(CLOUD, interval2, float4(240.0f * float(i), 0.0f, 240.0f, 180.0f)))
        cloud2->addAction(new RepeatForever(animation2))
        cloud2->setAnchor(0.5f, 0.5f)
        cloud2->setPosition(640.0f, 150.0f)
        cloud2->setScale(interval2, interval2)
        addChild(cloud2)

        var mountain: Sprite? = new Sprite(MOUNTAIN)
        mountain->setPosition(0.0f, -80.0f)
        addChild(mountain)

        var trees: Sprite? = new Sprite(TREE)
        trees->setPosition(0.0f, 360.0f)
        addChild(trees)

        var ground: Sprite? = new Sprite(GROUND)
        ground->setPosition(0.0f, 540.0f)
        addChild(ground)

        var rect: Rectangle? = new Rectangle(1280.0f, 720.0f, 0x5A000000)
        addChild(rect)

    def drawLevelButtons(): void
        for i in range(1, MAX_LEVEL + 1)
            if i <= getUserData().level
                var button: Button? = new Button(LEVEL_BUTTON(i), LEVEL_BUTTON_CLICKED(i))
                button->setAnchor(0.5f, 0.5f)
                button->setPosition(250.0f + 156.0f * float(i - 1), 240.0f)
                addChild(button)
                button->setFunc() <| @ [[=i]]
                    getApplication()->addScene("info{i}", new InfoScene(i))
                    getApplication()->changeSceneWithFading("info{i}", 0.5f)
                var clickOn: ClickOn? = new ClickOn(button)
                clickOn->setOnMouseDown() <| @ [[=button]]
                    button->onClick()
                    getSoundPool()->playEffect(BUTTON_CLICKED_SOUND)
                addEvent(clickOn)
            else
                var button: Sprite? = new Sprite(LOCK_LEVEL)
                button->setAnchor(0.5f, 0.5f)
                button->setPosition(250.0f + 156.0f * float(i - 1), 240.0f)
                addChild(button)

        var back: Button? = new Button(BUTTON_BACK, BUTTON_BACK_CLICKED)
        back->setAnchor(1.0f, 1.0f)
        back->setPosition(1280.0f - 20.0f, 720.0f - 20.0f)
        addChild(back)
        back->setFunc() <| @ [[=i]]
            // getApplication()->addScene("level", new LevelScene(1))
            getApplication()->changeSceneWithFading("title", 0.5f)
        var clickOn: ClickOn? = new ClickOn(back)
        clickOn->setOnMouseDown() <| @ [[=back]]
            back->onClick()
            getSoundPool()->playEffect(BUTTON_CLICKED_SOUND)
        addEvent(clickOn)

        var credit: Button? = new Button(BUTTON_CREDITS, BUTTON_CREDITS_CLICKED)
        credit->setAnchor(0.0f, 1.0f)
        credit->setPosition(20.0f, 720.0f - 20.0f)
        addChild(credit)
        credit->setFunc() <| @ [[=i]]
            // getApplication()->addScene("level", new LevelScene(1))
            getApplication()->changeSceneWithFading("credit", 0.5f)
        clickOn = new ClickOn(credit)
        clickOn->setOnMouseDown() <| @ [[=credit]]
            credit->onClick()
            getSoundPool()->playEffect(BUTTON_CLICKED_SOUND)
        addEvent(clickOn)

    def override initialize(): void
        drawBackground()
        drawLevelButtons()

        getSoundPool()->playBackground(ROUTER_MUSIC)
