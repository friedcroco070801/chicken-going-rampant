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

module title public

class TitleScene: Scene
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

        var cloud3: Sprite? = new Sprite(CLOUD, float4(0.0f, 0.0f, 240.0f, 180.0f))
        var animation3: Animation? = new Animation()
        var interval3: float = 0.85f + 0.6f * randFloat01()
        for i in range(0, 3)
            animation3->addFrame(new AnimFrame(CLOUD, interval3, float4(240.0f * float(i), 0.0f, 240.0f, 180.0f)))
        cloud3->addAction(new RepeatForever(animation3))
        cloud3->setAnchor(0.5f, 0.5f)
        cloud3->setPosition(1080.0f, 200.0f)
        cloud3->setScale(interval3, interval3)
        addChild(cloud3)

        var trees: Sprite? = new Sprite(TREE)
        trees->setPosition(0.0f, 360.0f)
        addChild(trees)

        var ground: Sprite? = new Sprite(GROUND)
        ground->setPosition(0.0f, 540.0f)
        addChild(ground)

        var clickOn: ClickOn? = new ClickOn(backdrop)
        clickOn->setOnMouseDown() <| @ [[=backdrop]]
            getSoundPool()->playEffect(BUTTON_CLICKED_SOUND)
            getApplication()->changeSceneWithFading("router", 0.5f)
        addEvent(clickOn)

    def drawInstruction(): void
        var logo: Sprite? = new Sprite(LOGO)
        logo->setAnchor(0.5f, 0.5f)
        logo->setScale(1.8f, 1.8f)
        logo->setPosition(640.0f, 280.0f - 500.0f)

        var seq: Sequence? = new Sequence()
        seq->addAction(new JumpBy(float2(0.0f, 500.0f), 300.0f, 0.75f))

        var miniSeq: Sequence? = new Sequence()
        miniSeq->addAction(new JumpBy(float2(0.0f, 0.0f), -20.0f, 2.0f))
        miniSeq->addAction(new JumpBy(float2(0.0f, 0.0f), 20.0f, 2.0f))
        seq->addAction(new RepeatForever(miniSeq))

        logo->addAction(seq)
        addChild(logo)

        var instruction: Sprite? = new Sprite(INSTRUCTION)
        instruction->setAnchor(0.5f, 0.4f)
        instruction->setPosition(640.0f, 630.0f)
        instruction->setScale(0.4f, 0.4f)
        instruction->setOpacity(0.0f)

        var seq2: Sequence? = new Sequence()
        seq2->addAction(new Wait(1.0f))

        var miniSeq2: Sequence? = new Sequence()
        miniSeq2->addAction(new FadeIn(0.2f))
        miniSeq2->addAction(new FadeOut(0.2f))
        seq2->addAction(new RepeatForever(miniSeq2))

        instruction->addAction(seq2)
        addChild(instruction)

    def drawRampantChicken(): void
        var knode: Node? = new Node()

        var miniSeq: Sequence? = new Sequence()
        miniSeq->addAction(new Wait(0.5f))
        
        var func: FuncCall? = new FuncCall()
        unsafe
            if randIntM11() == 1
                func->setFunc() <| @ [[&self]]
                    var chick: Character? = createCharacter(null, 001)
                    chick->move()
                    chick->setPosition(0.0f, LINE_GROUND)

                    var seq: Sequence? = new Sequence()
                    seq->addAction(new MoveBy(float2(1400.0f, 0.0f), 5.0f + 10.0f * randFloat01()))
                    seq->addAction(new Disappear())
                    
                    chick->addAction(seq)
                    self->addChild(chick)
            else
                func->setFunc() <| @ [[&self]]
                    var chick: Character? = createCharacter(null, 201)
                    chick->move()
                    chick->setPosition(1280.0f, LINE_GROUND)

                    var seq: Sequence? = new Sequence()
                    seq->addAction(new MoveBy(float2(-1400.0f, 0.0f), 5.0f + 10.0f * randFloat01()))
                    seq->addAction(new Disappear())
                    
                    chick->addAction(seq)
                    self->addChild(chick)
            miniSeq->addAction(func)

        knode->addAction(new RepeatForever(miniSeq))
        addChild(knode)

    def override initialize(): void
        drawBackground()
        drawInstruction()
        drawRampantChicken()

        getSoundPool()->playBackground(TITLE_MUSIC)
