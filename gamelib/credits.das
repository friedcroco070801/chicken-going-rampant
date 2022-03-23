require daslib/media
require pentwin/scene
require pentwin/node
require pentwin/sprite
require pentwin/application
require pentwin/button
require constant
require pentwin/soundpool

module credits public

class CreditScene: Scene
    def override initialize(): void
        var fore: Sprite? = new Sprite(RESULT_FORE)
        addChild(fore)

        var layer: Sprite? = new Sprite(LEVEL_INFO_LAYER)
        layer->setAnchor(0.5f, 0.5f)
        layer->setPosition(640.0f, 360.0f + 600.0f)
        addChild(layer)
        layer->addAction(new JumpBy(float2(0.0f, -600.0f), -250.0f, 0.60f))

        var text1: Sprite? = new Sprite(CREDIT)
        text1->setAnchor(0.5f, 0.5f)
        text1->setPosition(640.0f, 360.0f + 600.0f)
        text1->setScale(0.75f, 0.75f)
        addChild(text1)
        text1->addAction(new JumpBy(float2(0.0f, -600.0f), -250.0f, 0.60f))

        var back: Button? = new Button(BUTTON_BACK, BUTTON_BACK_CLICKED)
        back->setAnchor(1.0f, 1.0f)
        back->setPosition(1280.0f - 20.0f, 720.0f - 20.0f + 600.0f)
        addChild(back)
        back->setFunc() <| @ [[=i]]
            getApplication()->changeSceneWithFading("router", 0.5f)
        var clickOn: ClickOn? = new ClickOn(back)
        clickOn->setOnMouseDown() <| @ [[=back]]
            back->onClick()
            getSoundPool()->playEffect(BUTTON_CLICKED_SOUND)
        addEvent(clickOn)
        back->addAction(new JumpBy(float2(0.0f, -600.0f), -250.0f, 0.60f))
