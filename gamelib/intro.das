require daslib/media
require pentwin/scene
require pentwin/node
require pentwin/sprite
require pentwin/application
require constant

module intro public

class IntroScene: Scene  
    def override initialize(): void
        var fore: Sprite? = new Sprite(RESULT_FORE)
        addChild(fore)

        var intro: Sprite? = new Sprite(INTRO)
        intro->setPosition(640.0f, 360.0f)
        intro->setAnchor(0.5f, 0.5f)
        intro->setScale(0.5f, 0.5f)
        intro->setOpacity(0.0f)
        addChild(intro)

        var seq: Sequence? = new Sequence()
        seq->addAction(new FadeIn(1.0f))
        seq->addAction(new Wait(1.5f))

        var func: FuncCall? = new FuncCall()
        func->setFunc() <| @ [[=func]]
            getApplication()->changeSceneWithFading("title", 1.0f)

        seq->addAction(func)
        intro->addAction(seq)
