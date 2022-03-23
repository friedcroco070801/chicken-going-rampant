require daslib/media
require pentwin/scene
require pentwin/node
require pentwin/sprite
require pentwin/application
require pentwin/button
require level
require constant
require pentwin/soundpool

module info public

class InfoScene: Scene
    level: int = 1

    def InfoScene(_level: int)
        level = _level

    def override initialize(): void
        var fore: Sprite? = new Sprite(RESULT_FORE)
        addChild(fore)

        var layer: Sprite? = new Sprite(LEVEL_INFO_LAYER)
        layer->setAnchor(0.5f, 0.5f)
        layer->setPosition(640.0f, 360.0f + 600.0f)
        addChild(layer)
        layer->addAction(new JumpBy(float2(0.0f, -600.0f), -250.0f, 0.60f))

        var text1: Sprite? = new Sprite(LEVEL_INFO(level, 0))
        text1->setAnchor(0.0f, 0.5f)
        text1->setPosition(500.0f, 310.0f + 600.0f)
        if level == 6
            text1->setPosition(590.0f, 310.0f + 600.0f)
        text1->setScale(0.75f, 0.75f)
        addChild(text1)
        text1->addAction(new JumpBy(float2(0.0f, -600.0f), -250.0f, 0.60f))

        var text2: Sprite? = new Sprite(LEVEL_INFO(level, 1))
        text2->setAnchor(0.0f, 0.5f)
        text2->setPosition(500.0f, 410.0f + 600.0f)
        if level == 6
            text2->setPosition(590.0f, 410.0f + 600.0f)
        text2->setScale(0.75f, 0.75f)
        addChild(text2)
        text2->addAction(new JumpBy(float2(0.0f, -600.0f), -250.0f, 0.60f))

        var char1: Sprite?
        var char2: Sprite?

        if level == 1
            char1 = new Sprite(WORKER, float4(0.0f, 0.0f, 60.0f, 60.0f))
            var anim: Animation? = new Animation()
            for i in range(0, 8)
                anim->addFrame(new AnimFrame(WORKER, 0.1f, float4(60.0f * float(i), 0.0f, 60.0f, 60.0f)))
            char1->addAction(new RepeatForever(anim))
            var temp = createCharacter(null, 001)
            temp->idle()
            char2 = temp
        elif level == 2
            var temp = createCharacter(null, 101)
            char1 = temp
            temp = createCharacter(null, 202)
            temp->idle()
            char2 = temp
            char2->setColor(0x000000)
        elif level == 3
            var temp = createCharacter(null, 102)
            char1 = temp
            temp = createCharacter(null, 203)
            temp->idle()
            char2 = temp
            char2->setColor(0x000000)
        elif level == 4
            var temp = createCharacter(null, 103)
            char1 = temp
            temp = createCharacter(null, 101)
            temp->idle()
            char2 = temp
            char2->setColor(0x000000)
        elif level == 5
            var temp = createCharacter(null, 005)
            temp->idle()
            char1 = temp
            temp = createCharacter(null, 204)
            temp->idle()
            char2 = temp
            char2->setColor(0x000000)
        elif level == 6
            var temp = createCharacter(null, 205)
            temp->idle()
            char2 = temp
            char2->setColor(0x000000)

        if char1 != null
            char1->setAnchor(0.5f, 0.5f)
            char1->setPosition(420.0f, 300.0f + 600.0f)
            addChild(char1)
            char1->addAction(new JumpBy(float2(0.0f, -600.0f), -250.0f, 0.60f))

        if char2 != null
            char2->setAnchor(0.5f, 0.5f)
            char2->setPosition(420.0f, 420.0f + 600.0f)
            if level == 6
                char2->setPosition(420.0f, 360.0f + 600.0f)
            addChild(char2)
            char2->addAction(new JumpBy(float2(0.0f, -600.0f), -250.0f, 0.60f))

        var back: Button? = new Button(BUTTON_OKAY, BUTTON_OKAY_CLICKED)
        back->setAnchor(1.0f, 1.0f)
        back->setPosition(1280.0f - 20.0f, 720.0f - 20.0f + 600.0f)
        addChild(back)
        back->setFunc() <| @ [[=i]]
            getApplication()->addScene("level", new LevelScene(level))
            getApplication()->addScene("info{level + 1}", new InfoScene(level + 1))
            getApplication()->changeSceneWithFading("level", 0.5f)
        var clickOn: ClickOn? = new ClickOn(back)
        clickOn->setOnMouseDown() <| @ [[=back]]
            back->onClick()
            getSoundPool()->playEffect(BUTTON_CLICKED_SOUND)
        addEvent(clickOn)
        back->addAction(new JumpBy(float2(0.0f, -600.0f), -250.0f, 0.60f))
