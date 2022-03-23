require pentwin/scene
require pentwin/node
require pentwin/sprite
require pentwin/utils
require pentwin/application
require math
require constant
require effect
require counter
require unitbar
require pentwin/button
require leveldata
require userdata
require pentwin/soundpool

module level public

class LevelScene: Scene
    timer: float = 0.0f
    countTimer: int = 0 // number of centisecs
    isPaused: bool = false
    isEndGame: bool = false

    worker: int = 0

    armyBase: ArmyBase?
    enemyBase: EnemyBase?
    armyBaseHP: Counter?
    enemyBaseHP: Counter?

    armyList: array<Character?>
    eggList: array<Character?>
    enemyList: array<Character?>

    workerList: array<Sprite?>
    
    energyBar: Counter?
    energy: int = 0

    unitBars: array<UnitBar?>

    data: LevelData?

    def finalize
        for child in children
            unsafe
                delete child
        for event in events
            unsafe
                delete event
        for i in range(worker + 1, workerList |> length())
            unsafe
                delete workerList[i]
        unsafe
            delete data

    def LevelScene(_level: int)
        data = new LevelData(_level)

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

    def initializeBases(): void
        armyBase = new ArmyBase(unsafe(addr(self)), 50)
        addChild(armyBase)
        armyList |> push(armyBase)

        armyBaseHP = new Counter()
        armyBaseHP->setPosition(LINE_START - 60.0f + 20.0f, LINE_GROUND - 320.0f)
        armyBaseHP->setValue(armyBase.hp)
        armyBaseHP->setFontScale(0.2f)
        armyBaseHP->setLeftAligned(false)
        addChild(armyBaseHP)
        
        enemyBase = new EnemyBase(unsafe(addr(self)), data.enemyBaseHP)
        addChild(enemyBase)
        enemyList |> push(enemyBase)

        enemyBaseHP = new Counter()
        enemyBaseHP->setPosition(LINE_END + 60.0f - 20.0f, LINE_GROUND - 380.0f)
        enemyBaseHP->setValue(enemyBase.hp)
        enemyBaseHP->setFontScale(0.2f)
        addChild(enemyBaseHP)

    def initializeWorkers(): void
        for i in range(0, MAX_WORKER)
            var work: Sprite? = new Sprite(WORKER, float4(0.0f, 0.0f, 60.0f, 60.0f))
            work->setAnchor(0.5f, 1.0f)
            work->setPosition(30.0f * float(i + 1), LINE_GROUND)
            var anim: Animation? = new Animation()
            var rate: float = 0.05f + randFloat01() * 0.05f
            for j in range(0, 8)
                anim->addFrame(new AnimFrame(WORKER, rate, float4(60.0f * float(j), 0.0f, 60.0f, 60.0f)))
            work->addAction(new RepeatForever(anim))
            rate = 0.6f + randFloat01() * 0.6f
            work->setScale(rate * float(randIntM11()), rate)
            workerList |> push(work)
            
        sort(workerList) <| $ (a: Sprite?; b: Sprite?): bool
            return randFloat01() <= 0.5f

        addWorker()

    def addWorker(): void
        if worker < MAX_WORKER
            addChild(workerList[worker])
            worker = worker + 1

    def addArmy(var _army: Character?): void
        _army->setPosition(LINE_START, LINE_GROUND)
        armyList |> push(_army)
        addChild(_army)

    def addEgg(var _egg: Character?): void
        _egg->setPosition(LINE_START, LINE_GROUND)
        eggList |> push(_egg)
        addChild(_egg)

    def addEnemy(var _enemy: Character?): void
        _enemy->setPosition(LINE_END, LINE_GROUND)
        enemyList |> push(_enemy)
        addChild(_enemy)

    def drawEnergy(): void
        var energybarfore: Sprite? = new Sprite(ENERGY_BAR)
        energybarfore->setPosition(20.0f, 20.0f)
        addChild(energybarfore)

        energyBar = new Counter()
        energyBar->setPosition(240.0f, 61.0f)
        energyBar->setValue(0)
        energyBar->setFontScale(0.5f)
        energyBar->setLeftAligned(false)
        addChild(energyBar)

    def initializeUnitBar(): void
        // Worker bar
        var workerBar: UnitBar? = createUnitBar(000)
        workerBar->setPosition(200.0f, 675.0f)
        addChild(workerBar)
        unitBars |> push(workerBar)

        var clickWorker: ClickOn? = new ClickOn(workerBar)
        unsafe
            clickWorker->setOnMouseDown() <| @ [[=workerBar, &self]]
                if !workerBar.isDisabled
                    if self.energy >= workerBar.costValue
                        self.energy -= workerBar.costValue
                        workerBar->reset()
                        self->addWorker()
                        workerBar->setCost(COST_TABLE[self.worker])
                        if self.worker == MAX_WORKER
                            workerBar->setDisabled(true)
                    else
                        workerBar->redHightlightCost()
        addEvent(clickWorker)

        // Add army unit bar
        var avail := getUserData().chars
        for i in range(0, MAX_BAR - 1)
            if i < avail |> length()
                var code: int = avail[i]
                var unitBar: UnitBar? = createUnitBar(code)
                unitBar->setPosition(200.0f + 150.0f * float(i + 1), 675.0f)
                addChild(unitBar)

                var clickBar: ClickOn? = new ClickOn(unitBar)
                unsafe
                    clickBar->setOnMouseDown() <| @ [[=unitBar, &self, =code]]
                        if !unitBar.isDisabled && !unitBar.isRecharging
                            if self.energy >= unitBar.costValue
                                self.energy -= unitBar.costValue
                                unitBar->reset()
                                if code < 100
                                    self->addArmy(createCharacter(unsafe(addr(self)), code))
                                else
                                    self->addEgg(createCharacter(unsafe(addr(self)), code))
                            else
                                unitBar->redHightlightCost()
                addEvent(clickBar)

                unitBars |> push(unitBar)
            else
                var unitBar: UnitBar? = createUnitBar(-1)
                unitBar->setPosition(200.0f + 150.0f * float(i + 1), 675.0f)
                addChild(unitBar)

                unitBars |> push(unitBar)

    def drawButtons(): void
        var pauseButton: Button? = new Button(BUTTON_PAUSE, BUTTON_PAUSE_CLICKED)
        pauseButton->setAnchor(1.0f, 0.0f)
        pauseButton->setPosition(1280.0f - 20.0f, 20.0f)
        unsafe
            pauseButton->setFunc() <| @ [[&self]]
                self->pause()

                var fore: Sprite? = new Sprite(RESULT_FORE)
                fore->setOpacity(0.7f)
                self->addChild(fore)

                var center: float2 = float2(640.0f, 360.0f)

                var layer: Sprite? = new Sprite(PAUSE_LAYER)
                layer->setAnchor(0.5f, 0.5f)
                layer->setPosition(center.x, center.y)
                self->addChild(layer)
                
                var restart: Button? = new Button(BUTTON_RESTART, BUTTON_RESTART_CLICKED)
                restart->setAnchor(0.5f, 0.5f)
                restart->setPosition(center.x, center.y)
                restart->setFunc() <| @ [[=restart]]
                    getApplication()->addScene("level", new LevelScene(data.level))
                    getApplication()->changeSceneWithFading("level", 0.5f)
                var restartClick: ClickOn? = new ClickOn(restart)
                restartClick->setOnMouseDown() <| @ [[=restart]]
                    restart->onClick()
                    getSoundPool()->playEffect(BUTTON_CLICKED_SOUND)
                self->addChild(restart)
                self->addEvent(restartClick)

                var mainmenu: Button? = new Button(BUTTON_MAINMENU, BUTTON_MAINMENU_CLICKED)
                mainmenu->setAnchor(0.5f, 0.5f)
                mainmenu->setPosition(center.x, center.y + 90.0f)
                mainmenu->setFunc() <| @ [[=mainmenu]]
                    // getApplication()->addScene("level", new LevelScene(data.level))
                    getApplication()->changeSceneWithFading("router", 0.5f)
                var mainClick: ClickOn? = new ClickOn(mainmenu)
                mainClick->setOnMouseDown() <| @ [[=mainmenu]]
                    mainmenu->onClick()
                    getSoundPool()->playEffect(BUTTON_CLICKED_SOUND)
                self->addChild(mainmenu)
                self->addEvent(mainClick)

                var resumeButton: Button? = new Button(BUTTON_RESUME, BUTTON_RESUME_CLICKED)
                resumeButton->setAnchor(0.5f, 0.5f)
                resumeButton->setPosition(center.x, center.y - 90.0f)
                unsafe
                    resumeButton->setFunc() <| @ [[=resumeButton, =mainmenu, =restart, =layer, =fore, &self]]
                        self->resume()
                        resumeButton->removeFromScene()
                        mainmenu->removeFromScene()
                        restart->removeFromScene()
                        layer->removeFromScene()
                        fore->removeFromScene()
                var resumeButtonClick: ClickOn? = new ClickOn(resumeButton)
                resumeButtonClick->setOnMouseDown() <| @ [[=resumeButton]]
                    resumeButton->onClick()
                    getSoundPool()->playEffect(BUTTON_CLICKED_SOUND)
                self->addChild(resumeButton)
                self->addEvent(resumeButtonClick)
        var pauseClick: ClickOn? = new ClickOn(pauseButton)
        pauseClick->setOnMouseDown() <| @ [[=pauseButton]]
            pauseButton->onClick()
            getSoundPool()->playEffect(BUTTON_CLICKED_SOUND)
        addChild(pauseButton)
        addEvent(pauseClick)

    def override initialize(): void
        // Draw backgrounds
        drawBackground()

        // Initialize bases
        initializeBases()

        // Initialize workers
        initializeWorkers()

        // Draw energy bar
        drawEnergy()

        // Initialize unit bar
        initializeUnitBar()

        // Draw pause button
        drawButtons()

        getSoundPool()->playBackground(GAME_MUSIC)

    def override update(dt: float): void
        if !isPaused
            timer = timer + dt
            while timer >= CENTISEC
                timer -= CENTISEC
                updateLogicPerCs()
        
        energyBar->setValue(energy)
        armyBaseHP->setValue(armyBase.hp)
        enemyBaseHP->setValue(enemyBase.hp)

        Scene`update(self, dt)

    def updateLogicPerCs(): void
        if !isPaused
            countTimer++
            
            // Enemy spawns
            var arr: array<int> <- data->updateAndGetEnemiesAt(countTimer)
            for charCode in arr
                addEnemy(createCharacter(unsafe(addr(self)), charCode))

            // Gaining energy
            if countTimer % 10 == 0
                energy = min(energy + WORKING_SPEED[worker], 9999)

            // Remove dead characters
            var i: int = 0
            while i < armyList |> length()
                if armyList[i]->isDead()
                    armyList |> erase(i)
                    i--
                i++
            i = 0
            while i < eggList |> length()
                if eggList[i]->isDead()
                    eggList |> erase(i)
                    i--
                i++
            i = 0
            while i < enemyList |> length()
                if enemyList[i]->isDead()
                    enemyList |> erase(i)
                    i--
                i++

            // Update each character
            for char in armyList
                char->updateLogicPerCs()
            for char in eggList
                char->updateLogicPerCs()
            for char in enemyList
                char->updateLogicPerCs()
            for unitBar in unitBars
                unitBar->updateLogicPerCs()

            // Check win/lose conditions
            if !isEndGame
                if isLoser()
                    lose()
                    isEndGame = true
                    return
                if isWinner()
                    win()
                    isEndGame = true

    def pause()
        self->pauseAllEvents()
        self->pauseAllActions()
        self.isPaused = true

    def resume()
        self->resumeAllEvents()
        self->resumeAllActions()
        self.isPaused = false

    def isWinner(): bool
        return enemyBase->isDead()

    def win(): void
        var temp: Node? = new Node()
        var seq: Sequence? = new Sequence()

        // Wait
        seq->addAction(new Wait(2.0f))
        
        // Flash and pause
        var flash: FuncCall? = new FuncCall()
        unsafe
            flash->setFunc() <| @ [[&self]]
                self->pauseAllEvents()
                self->pauseAllActions()
                self.isPaused = true
                getSoundPool()->stopBackgroundMusic()

                var white: Sprite? = new Sprite(RESULT_FLASH)
                white->setOpacity(0.0f)

                var inSeq: Sequence? = new Sequence()
                inSeq->addAction(new FadeIn(0.1f))
                inSeq->addAction(new FadeOut(0.1f))
                inSeq->addAction(new Wait(1.0f))

                // Fore fade in and victory
                var victory: FuncCall? = new FuncCall()
                unsafe
                    victory->setFunc() <| @ [[&self]]
                        getSoundPool()->playEffect(VICTORY_SOUND)
                        getSoundPool()->playBackground(AFTER_LEVEL_MUSIC)

                        // Fore fading
                        var fore: Sprite? = new Sprite(RESULT_FORE)
                        fore->setOpacity(0.0f)
                        fore->addAction(new FadeTo(0.7f, 1.0f))
                        self->addChild(fore)

                        // Victory titling
                        var victor: Sprite? = new Sprite(RESULT_VICTORY)
                        victor->setOpacity(0.0f)
                        victor->setPosition(640.0f, 360.0f)
                        victor->setAnchor(0.5f, 0.5f)
                        victor->setScale(3.0f, 3.0f)
                        var vicSeq: Sequence? = new Sequence()
                        vicSeq->addAction(new FadeIn(0.3f))
                        victor->addAction(vicSeq)
                        victor->addAction(new ScaleBy(float2(0.4f, 0.4f), 0.3f))
                        self->addChild(victor)

                        // Starburst
                        var inSeq: Sequence? = new Sequence()
                        inSeq->addAction(new Wait(0.3f))
                        inSeq->addAction(new StarBurst(2.0f, -100.0f, float2(640.0f, 360.0f), float2(1000.0f, 600.0f), 70))
                        fore->addAction(inSeq)

                        // Victory fadout
                        vicSeq->addAction(new Wait(1.7f))
                        vicSeq->addAction(new FadeOut(0.3f))

                        // Pop up message
                        var messPop: FuncCall? = new FuncCall()
                        unsafe
                            messPop->setFunc() <| @ [[&self]]
                                var center: float2 = float2(640.0f, 360.f)
                                var layer: Sprite? = new Sprite(MESSAGE_LAYER)
                                layer->setAnchor(0.5f, 0.5f)
                                layer->setPosition(center.x, center.y + 500.0f)
                                self->addChild(layer)
                                var jump1: JumpBy? = new JumpBy(float2(0.0f, -500.0f), -250.0f, 0.6f)
                                layer->addAction(jump1)

                                var text: Sprite? = new Sprite(data.level < MAX_LEVEL ? MESSAGE_WIN : MESSAGE_COMPLETE)
                                text->setAnchor(0.5f, 0.5f)
                                text->setPosition(center.x, center.y - 30.0f + 500.0f)
                                text->setScale(0.9f, 0.9f)
                                self->addChild(text)
                                var jump2: JumpBy? = new JumpBy(float2(0.0f, -500.0f), -250.0f, 0.6f)
                                text->addAction(jump2)

                                if data.level == getUserData().level && data.level < MAX_LEVEL
                                    var nextLevel: Button? = new Button(BUTTON_NEXTLEVEL, BUTTON_NEXTLEVEL_CLICKED)
                                    nextLevel->setAnchor(0.5f, 0.5f)
                                    nextLevel->setPosition(center.x + 105.0f, center.y + 30.0f + 500.0f)
                                    nextLevel->setFunc() <| @ [[=nextLevel]]
                                        // getApplication()->addScene("level", new LevelScene(data.level + 1))
                                        getApplication()->changeSceneWithFading("info{data.level + 1}", 0.5f)
                                    var nextClick: ClickOn? = new ClickOn(nextLevel)
                                    nextClick->setOnMouseDown() <| @ [[=nextLevel]]
                                        nextLevel->onClick()
                                        getSoundPool()->playEffect(BUTTON_CLICKED_SOUND)
                                    self->addChild(nextLevel)
                                    self->addEvent(nextClick)
                                    var jump3: JumpBy? = new JumpBy(float2(0.0f, -500.0f), -250.0f, 0.6f)
                                    nextLevel->addAction(jump3)

                                var mainmenu: Button? = new Button(BUTTON_MAINMENU, BUTTON_MAINMENU_CLICKED)
                                mainmenu->setAnchor(0.5f, 0.5f)
                                if data.level == getUserData().level && data.level < MAX_LEVEL
                                    mainmenu->setPosition(center.x - 105.0f, center.y + 30.0f + 500.0f)
                                else
                                    mainmenu->setPosition(center.x, center.y + 30.0f + 500.0f)
                                mainmenu->setFunc() <| @ [[=mainmenu]]
                                    // getApplication()->addScene("level", new LevelScene(data.level))
                                    getApplication()->changeSceneWithFading("router", 0.5f)
                                var mainClick: ClickOn? = new ClickOn(mainmenu)
                                mainClick->setOnMouseDown() <| @ [[=mainmenu]]
                                    mainmenu->onClick()
                                    getSoundPool()->playEffect(BUTTON_CLICKED_SOUND)
                                self->addChild(mainmenu)
                                self->addEvent(mainClick)
                                var jump4: JumpBy? = new JumpBy(float2(0.0f, -500.0f), -250.0f, 0.6f)
                                mainmenu->addAction(jump4)

                                // Save data
                                if data.level == getUserData().level
                                    getUserData().level++ 
                                if getUserData().chars |> find_index(data.reward) == -1
                                    getUserData().chars |> push(data.reward)
                                getUserData()->saveData()

                            vicSeq->addAction(messPop)

                        vicSeq->addAction(new Disappear())
                    inSeq->addAction(victory)

                white->addAction(inSeq)

                self->addChild(white)
            seq->addAction(flash)

        temp->addAction(seq)
        addChild(temp)

    def isLoser(): bool
        return armyBase->isDead()

    def lose(): void
        var temp: Node? = new Node()
        var seq: Sequence? = new Sequence()

        // Wait
        seq->addAction(new Wait(2.0f))
        
        // Flash and pause
        var flash: FuncCall? = new FuncCall()
        unsafe
            flash->setFunc() <| @ [[&self]]
                self->pauseAllEvents()
                self->pauseAllActions()
                self.isPaused = true
                getSoundPool()->stopBackgroundMusic()

                var white: Sprite? = new Sprite(RESULT_FLASH)
                white->setOpacity(0.0f)

                var inSeq: Sequence? = new Sequence()
                inSeq->addAction(new FadeIn(0.1f))
                inSeq->addAction(new FadeOut(0.1f))
                inSeq->addAction(new Wait(1.0f))

                // Fore fade in and defeat
                var defeat: FuncCall? = new FuncCall()
                unsafe
                    defeat->setFunc() <| @ [[&self]]
                        getSoundPool()->playBackground(AFTER_LEVEL_MUSIC)

                        // Fore fading
                        var fore: Sprite? = new Sprite(RESULT_FORE)
                        fore->setOpacity(0.0f)
                        fore->addAction(new FadeTo(0.7f, 1.0f))
                        self->addChild(fore)

                        // Lose titling
                        var victor: Sprite? = new Sprite(RESULT_LOSE)
                        victor->setOpacity(0.0f)
                        victor->setPosition(640.0f, 360.0f)
                        victor->setAnchor(0.5f, 0.5f)
                        victor->setScale(1.2f, 1.2f)
                        var vicSeq: Sequence? = new Sequence()
                        vicSeq->addAction(new FadeIn(0.75f))
                        victor->addAction(vicSeq)
                        self->addChild(victor)

                        // Lose fadout
                        vicSeq->addAction(new Wait(2.0f))
                        vicSeq->addAction(new FadeOut(0.5f))

                        // Pop up message
                        var messPop: FuncCall? = new FuncCall()
                        unsafe
                            messPop->setFunc() <| @ [[&self]]
                                var center: float2 = float2(640.0f, 360.f)
                                var layer: Sprite? = new Sprite(MESSAGE_LAYER)
                                layer->setAnchor(0.5f, 0.5f)
                                layer->setPosition(center.x, center.y + 500.0f)
                                self->addChild(layer)
                                var jump1: JumpBy? = new JumpBy(float2(0.0f, -500.0f), -250.0f, 0.6f)
                                layer->addAction(jump1)

                                var text: Sprite? = new Sprite(MESSAGE_LOSE)
                                text->setAnchor(0.5f, 0.5f)
                                text->setPosition(center.x, center.y - 30.0f + 500.0f)
                                text->setScale(0.9f, 0.9f)
                                self->addChild(text)
                                var jump2: JumpBy? = new JumpBy(float2(0.0f, -500.0f), -250.0f, 0.6f)
                                text->addAction(jump2)

                                var restartLevel: Button? = new Button(BUTTON_RESTART, BUTTON_RESTART_CLICKED)
                                restartLevel->setAnchor(0.5f, 0.5f)
                                restartLevel->setPosition(center.x + 105.0f, center.y + 30.0f + 500.0f)
                                restartLevel->setFunc() <| @ [[=restartLevel]]
                                    getApplication()->addScene("level", new LevelScene(data.level))
                                    getApplication()->changeSceneWithFading("level", 0.5f)
                                var nextClick: ClickOn? = new ClickOn(restartLevel)
                                nextClick->setOnMouseDown() <| @ [[=restartLevel]]
                                    restartLevel->onClick()
                                    getSoundPool()->playEffect(BUTTON_CLICKED_SOUND)
                                self->addChild(restartLevel)
                                self->addEvent(nextClick)
                                var jump3: JumpBy? = new JumpBy(float2(0.0f, -500.0f), -250.0f, 0.6f)
                                restartLevel->addAction(jump3)

                                var mainmenu: Button? = new Button(BUTTON_MAINMENU, BUTTON_MAINMENU_CLICKED)
                                mainmenu->setAnchor(0.5f, 0.5f)
                                mainmenu->setPosition(center.x - 105.0f, center.y + 30.0f + 500.0f)
                                mainmenu->setFunc() <| @ [[=mainmenu]]
                                    // getApplication()->addScene("level", new LevelScene(data.level))
                                    getApplication()->changeSceneWithFading("router", 0.5f)
                                var mainClick: ClickOn? = new ClickOn(mainmenu)
                                mainClick->setOnMouseDown() <| @ [[=mainmenu]]
                                    mainmenu->onClick()
                                    getSoundPool()->playEffect(BUTTON_CLICKED_SOUND)
                                self->addChild(mainmenu)
                                self->addEvent(mainClick)
                                var jump4: JumpBy? = new JumpBy(float2(0.0f, -500.0f), -250.0f, 0.6f)
                                mainmenu->addAction(jump4)
                            vicSeq->addAction(messPop)

                        vicSeq->addAction(new Disappear())
                    inSeq->addAction(defeat)

                white->addAction(inSeq)

                self->addChild(white)
            seq->addAction(flash)

        temp->addAction(seq)
        addChild(temp)

class Character: Sprite
    level: LevelScene?

    charCode: CharacterCode = CharacterCode NONE
    attackType: AttackType = AttackType NONE
    charState: CharacterState = CharacterState IDLING

    hp: int = 0
    speed: float = 0.0f // per second
    damage: int = 0

    idleInterval: float = 0.0f
    idleTimer: float = 0.0f

    noticeFront: float = 0.0f
    noticeBack: float = 0.0f

    rangeFront: float = 0.0f
    rangeBack: float = 0.0f

    idleAnimation: Action?
    moveAnimation: Action? 
    attackAnimation: Action?  
    dieAnimation: Action?
    takeDamageAnimation: Action?

    dieOnce: bool = false

    def finalize
        for action in actionLists
            unsafe
                delete action
        unsafe
            delete idleAnimation
        unsafe
            delete moveAnimation
        unsafe
            delete attackAnimation
        unsafe
            delete dieAnimation
        unsafe
            delete takeDamageAnimation
        unsafe
            pass // delete image

    def updateLogicPerCs(): void
        pass

    def animateIdle(): void
        pass

    def animateMove(): void
        pass

    def animateAttack(): void
        pass

    def animateDie(): void
        if !dieOnce
            pauseAllActions()
            dieAnimation->reset()
            addAction(dieAnimation)
            dieOnce = true

    def animateTakeDamage(): void
        if takeDamageAnimation?.isDisabled ?? false && !isDead()
            takeDamageAnimation->reset()
            addAction(takeDamageAnimation)

    def idle(): void
        pass

    def move(): void
        pass

    def attack(): void
        pass

    def die(): void
        animateDie()

    def takeDamage(_dam: int): void
        if _dam <= 0
            return
        hp = max(hp - _dam, 0)
        getSoundPool()->playEffect(DAMAGE_SOUND)
        animateTakeDamage()
        if isDead()
            die()

    def isDead(): bool
        return hp <= 0

class TowerBase: Character
    def finalize
        for action in actionLists
            unsafe
                delete action
        unsafe
            delete idleAnimation
        unsafe
            delete moveAnimation
        unsafe
            delete attackAnimation
        unsafe
            delete dieAnimation
        unsafe
            delete takeDamageAnimation
        unsafe
            pass // delete image

    def TowerBase(_level: LevelScene?; _hp: int)
        // Parmeters
        level = _level
        hp = _hp

        // Animation
        // Take damage
        var seq: Sequence? = new Sequence()
        seq->addAction(new MoveAnchorBy(float2(-0.04f, 0.0f), 0.025f))
        seq->addAction(new MoveAnchorBy(float2(0.08f, 0.0f), 0.05f))
        seq->addAction(new MoveAnchorBy(float2(-0.04f, 0.0f), 0.025f))
        seq->addAction(new MoveAnchorBy(float2(-0.02f, 0.0f), 0.025f))
        seq->addAction(new MoveAnchorBy(float2(0.04f, 0.0f), 0.05f))
        seq->addAction(new MoveAnchorBy(float2(-0.02f, 0.0f), 0.025f))
        seq->addAction(new MoveAnchorBy(float2(-0.01f, 0.0f), 0.025f))
        seq->addAction(new MoveAnchorBy(float2(0.02f, 0.0f), 0.05f))
        seq->addAction(new MoveAnchorBy(float2(-0.01f, 0.0f), 0.025f))
        seq->setDisable()
        seq->keepOnDisabled()
        takeDamageAnimation = seq

        // Die
        dieAnimation = new FuncCallStored(3)
        dieAnimation->setDisable()
        dieAnimation->keepOnDisabled()

class ArmyBase: TowerBase
    def finalize
        for action in actionLists
            unsafe
                delete action
        unsafe
            delete idleAnimation
        unsafe
            delete moveAnimation
        unsafe
            delete attackAnimation
        unsafe
            delete dieAnimation
        unsafe
            delete takeDamageAnimation
        unsafe
            pass // delete image

    def ArmyBase(_level: LevelScene?; _hp: int)
        // Initialize sprite
        Sprite`Sprite(self, ARMY_BASE)
        setAnchor(1.0f, 1.0f)
        setPosition(LINE_START, LINE_GROUND)

        // Initialize tower base
        TowerBase`TowerBase(self, _level, _hp)

        // Parmeters
        charCode = CharacterCode A00_BASE

    def override funcCallStored3(): void
        var seq2: Sequence? = new Sequence()
        seq2->addAction(new MoveAnchorBy(float2(-0.04f, 0.0f), 0.0125f))
        seq2->addAction(new MoveAnchorBy(float2(0.08f, 0.0f), 0.025f))
        seq2->addAction(new MoveAnchorBy(float2(-0.04f, 0.0f), 0.0125f))
        addAction(new RepeatForever(seq2))

        var seq: Sequence? = new Sequence()
        seq->addAction(new Wait(5.0f))
        seq->addAction(new Disappear())
        var tempNode: Node? = new Node()
        tempNode->addAction(seq)
        level->addChild(tempNode)
        tempNode->addAction(new Explosion(5.0f, float2(x - 60.0f, y - 60.0f), 80.0f, 150))

        getSoundPool()->playEffect(EXPLOSION_SOUND)

class EnemyBase: TowerBase
    def finalize
        for action in actionLists
            unsafe
                delete action
        unsafe
            delete idleAnimation
        unsafe
            delete moveAnimation
        unsafe
            delete attackAnimation
        unsafe
            delete dieAnimation
        unsafe
            delete takeDamageAnimation
        unsafe
            pass // delete image

    def EnemyBase(_level: LevelScene?; _hp: int)
        // Initialize sprite
        Sprite`Sprite(self, ENEMY_BASE)
        setAnchor(0.0f, 1.0f)
        setPosition(LINE_END, LINE_GROUND)

        // Initialize tower base
        TowerBase`TowerBase(self, _level, _hp)

        // Parmeters
        charCode = CharacterCode E00_BASE

    def override funcCallStored3(): void
        var seq2: Sequence? = new Sequence()
        seq2->addAction(new MoveAnchorBy(float2(-0.04f, 0.0f), 0.0125f))
        seq2->addAction(new MoveAnchorBy(float2(0.08f, 0.0f), 0.025f))
        seq2->addAction(new MoveAnchorBy(float2(-0.04f, 0.0f), 0.0125f))
        addAction(new RepeatForever(seq2))

        var seq: Sequence? = new Sequence()
        seq->addAction(new Wait(5.0f))
        seq->addAction(new Disappear())
        var tempNode: Node? = new Node()
        tempNode->addAction(seq)
        level->addChild(tempNode)
        tempNode->addAction(new Explosion(5.0f, float2(x + 60.0f, y - 150.0f), 80.0f, 150))

        getSoundPool()->playEffect(EXPLOSION_SOUND)

/*
=======================================================================================
ARMY DEFINITIONS
=======================================================================================
*/
class Army: Character
    def finalize
        for action in actionLists
            unsafe
                delete action
        unsafe
            delete idleAnimation
        unsafe
            delete moveAnimation
        unsafe
            delete attackAnimation
        unsafe
            delete dieAnimation
        unsafe
            delete takeDamageAnimation
        unsafe
            pass // delete image

    def Army(_level: LevelScene?; _charCode: CharacterCode; _attackType: AttackType; _hp: int; _speed: float; _damage: int; _idleInterval: float; _noticeFront: float; _noticeBack: float; _rangeFront: float; _rangeBack: float)
        // Sprite
        setPosition(LINE_START, LINE_GROUND)
        
        // Parameters
        level = _level
        charCode = _charCode
        attackType = _attackType
        hp = _hp
        speed = _speed
        damage = _damage
        idleInterval = _idleInterval
        noticeFront = _noticeFront
        noticeBack = _noticeBack
        rangeFront = _rangeFront
        rangeBack = _rangeBack

        // Animation
        // Take damage
        var seq: Sequence? = new Sequence()
        seq->addAction(new TintTo(0xFF7070, 0.0f))
        seq->addAction(new Wait(0.1f))
        seq->addAction(new TintTo(0xffffff, 0.0f))
        seq->setDisable()
        takeDamageAnimation = seq
        seq->keepOnDisabled()

        // Die
        var seq2: Sequence? = new Sequence()
        seq2->addAction(new JumpBy(float2(-JUMP_DIE_DELTA_X, JUMP_DIE_DELTA_Y), JUMP_DIE_HEIGHT, JUMP_DIE_INTERVAL))
        seq2->addAction(new Disappear())
        seq2->setDisable()
        dieAnimation = seq2
        seq2->keepOnDisabled()

    def checkHasEnemy(): bool
        for enemy in level.enemyList
            var delta = enemy.x - x
            if delta >= noticeBack && delta <= noticeFront
                return true
        return false

    def damageEnemy(): void
        if attackType == AttackType AREA
            for enemy in level.enemyList
                var delta = enemy.x - x
                if delta >= rangeBack && delta <= rangeFront
                    enemy->takeDamage(damage)
        else
            var minDelta: float = 0.0f
            var target: Character? = null
            for enemy in level.enemyList
                var delta = enemy.x - x
                if delta >= rangeBack && delta <= rangeFront
                    if target == null
                        target = enemy
                        minDelta = delta
                    elif minDelta > delta
                        target = enemy
                        minDelta = delta
            if target != null
                target->takeDamage(damage)

    def override updateLogicPerCs(): void
        if !isDead()
            var hasEnemy: bool = checkHasEnemy()

            // Change state
            // Idle --> Move
            if !hasEnemy && charState == CharacterState IDLING
                move()
            
            // Idle --> Idle
            if idleTimer > 0.0f && hasEnemy && charState == CharacterState IDLING
                idleTimer = idleTimer - CENTISEC

            // Idle --> Attack
            if idleTimer <= 0.0f && hasEnemy && charState == CharacterState IDLING
                attack()

            // Move --> Idle
            if idleTimer > 0.0f && hasEnemy && charState == CharacterState MOVING
                idleTimer = idleTimer - CENTISEC
                idle()

            // Move --> Attack
            if idleTimer <= 0.0f && hasEnemy && charState == CharacterState MOVING
                attack()

            // Change position when moving
            if !isDead() && charState == CharacterState MOVING
                x = min(x + speed * CENTISEC, LINE_END)

    def override idle(): void
        charState = CharacterState IDLING
        idleTimer = idleInterval
        animateIdle()

    def override animateIdle(): void
        moveAnimation->setDisable()
        attackAnimation->setDisable()
        idleAnimation->reset()
        addAction(idleAnimation)

    def override move(): void
        charState = CharacterState MOVING
        animateMove()

    def override animateMove(): void
        moveAnimation->reset()
        attackAnimation->setDisable()
        idleAnimation->setDisable()
        addAction(moveAnimation)

    def override attack(): void
        charState = CharacterState ATTACKING
        animateAttack()

    def override animateAttack(): void
        moveAnimation->setDisable()
        attackAnimation->reset()
        idleAnimation->setDisable()
        addAction(attackAnimation)

    def override funcCallStored1(): void
        damageEnemy()

    def override funcCallStored2(): void
        idle()

class Army01Chica: Army
    def finalize
        for action in actionLists
            unsafe
                delete action
        unsafe
            delete idleAnimation
        unsafe
            delete moveAnimation
        unsafe
            delete attackAnimation
        unsafe
            delete dieAnimation
        unsafe
            delete takeDamageAnimation
        unsafe
            pass // delete image

    def Army01Chica(_level: LevelScene?)
        // Initialize sprite
        Sprite`Sprite(self, ARMY01, float4(0.0f, 0.0f, 60.0f, 80.0f))
        setAnchor(1.0f, 1.0f)
        Army`Army(self, _level, CharacterCode A01_NORMAL, AttackType SINGLE, 10, 30.0f, 1, 1.0f, 5.0f, -30.0f, 5.0f, -30.0f)

        // Animation
        // Move
        var seq: Animation? = new Animation()
        for i in range(0, 4)
            seq->addFrame(new AnimFrame(ARMY01, 0.2f, float4(60.0f * float(i % 4), 80.0f * float(i / 4), 60.0f, 80.0f)))
        moveAnimation = new RepeatForever(seq)
        moveAnimation->setDisable()
        moveAnimation->keepOnDisabled()

        // Idle
        var seq2: Animation? = new Animation()
        for i in range(4, 8)
            seq2->addFrame(new AnimFrame(ARMY01, 0.2f, float4(60.0f * float(i % 4), 80.0f * float(i / 4), 60.0f, 80.0f)))
        idleAnimation = new RepeatForever(seq2)
        idleAnimation->setDisable()
        idleAnimation->keepOnDisabled()

        // Attack
        var allSeq: Sequence? = new Sequence()
        var seq3: Animation? = new Animation()
        for i in range(8, 12)
            seq3->addFrame(new AnimFrame(ARMY01, 0.075f, float4(60.0f * float(i % 4), 80.0f * float(i / 4), 60.0f, 80.0f)))
        allSeq->addAction(seq3)

        var dam: FuncCallStored? = new FuncCallStored(1)
        allSeq->addAction(dam)

        var seq4: Animation? = new Animation()
        for i in range(12, 14)
            seq4->addFrame(new AnimFrame(ARMY01, 0.1f, float4(60.0f * float(i % 4), 80.0f * float(i / 4), 60.0f, 80.0f)))
        allSeq->addAction(seq4)

        var dam2: FuncCallStored? = new FuncCallStored(2)
        allSeq->addAction(dam2)

        attackAnimation = allSeq
        attackAnimation->setDisable()
        attackAnimation->keepOnDisabled()

class Army02Chiburn: Army
    def finalize
        for action in actionLists
            unsafe
                delete action
        unsafe
            delete idleAnimation
        unsafe
            delete moveAnimation
        unsafe
            delete attackAnimation
        unsafe
            delete dieAnimation
        unsafe
            delete takeDamageAnimation
        unsafe
            pass // delete image

    def Army02Chiburn(_level: LevelScene?)
        // Initialize sprite
        Sprite`Sprite(self, ARMY02, float4(0.0f, 0.0f, 60.0f, 80.0f))
        setAnchor(1.0f, 1.0f)
        Army`Army(self, _level, CharacterCode A02_FIRE, AttackType SINGLE, 10, 40.0f, 2, 0.67f, 5.0f, -30.0f, 5.0f, -30.0f)

        // Animation
        // Move
        var seq: Animation? = new Animation()
        for i in range(0, 4)
            seq->addFrame(new AnimFrame(ARMY02, 0.1f, float4(60.0f * float(i % 4), 80.0f * float(i / 4), 60.0f, 80.0f)))
        moveAnimation = new RepeatForever(seq)
        moveAnimation->setDisable()
        moveAnimation->keepOnDisabled()

        // Idle
        var seq2: Animation? = new Animation()
        for i in range(4, 8)
            seq2->addFrame(new AnimFrame(ARMY02, 0.1f, float4(60.0f * float(i % 4), 80.0f * float(i / 4), 60.0f, 80.0f)))
        idleAnimation = new RepeatForever(seq2)
        idleAnimation->setDisable()
        idleAnimation->keepOnDisabled()

        // Attack
        var allSeq: Sequence? = new Sequence()
        var seq3: Animation? = new Animation()
        for i in range(8, 12)
            seq3->addFrame(new AnimFrame(ARMY02, 0.05f, float4(60.0f * float(i % 4), 80.0f * float(i / 4), 60.0f, 80.0f)))
        for i in range(12, 14)
            seq3->addFrame(new AnimFrame(ARMY02, 0.05f, float4(60.0f * float(i % 4), 80.0f * float(i / 4), 60.0f, 80.0f)))
        allSeq->addAction(seq3)

        var allSeq2: Sequence? = new Sequence()
        allSeq2->addAction(new Wait(4.0f * 0.05f))

        var dam: FuncCallStored? = new FuncCallStored(1)
        allSeq2->addAction(dam)
        allSeq2->addAction(new Wait(2.0f * 0.05f))
        var dam2: FuncCallStored? = new FuncCallStored(2)
        allSeq2->addAction(dam2)

        var par: Parallel? = new Parallel()
        par->addAction(allSeq)
        par->addAction(allSeq2)

        attackAnimation = par
        attackAnimation->setDisable()
        attackAnimation->keepOnDisabled()

class Army03Chirystal: Army
    def finalize
        for action in actionLists
            unsafe
                delete action
        unsafe
            delete idleAnimation
        unsafe
            delete moveAnimation
        unsafe
            delete attackAnimation
        unsafe
            delete dieAnimation
        unsafe
            delete takeDamageAnimation
        unsafe
            pass // delete image

    def Army03Chirystal(_level: LevelScene?)
        // Initialize sprite
        Sprite`Sprite(self, ARMY03, float4(0.0f, 0.0f, 60.0f, 100.0f))
        setAnchor(1.0f, 1.0f)
        Army`Army(self, _level, CharacterCode A03_ICE, AttackType SINGLE, 30, 25.0f, 1, 4.0f, 0.0f, -30.0f, 0.0f, -30.0f)

        // Animation
        // Move
        var seq: Animation? = new Animation()
        for i in range(0, 4)
            seq->addFrame(new AnimFrame(ARMY03, 0.2f, float4(60.0f * float(i % 4), 100.0f * float(i / 4), 60.0f, 100.0f)))
        moveAnimation = new RepeatForever(seq)
        moveAnimation->setDisable()
        moveAnimation->keepOnDisabled()

        // Idle
        var seq2: Animation? = new Animation()
        for i in range(4, 8)
            seq2->addFrame(new AnimFrame(ARMY03, 0.2f, float4(60.0f * float(i % 4), 100.0f * float(i / 4), 60.0f, 100.0f)))
        idleAnimation = new RepeatForever(seq2)
        idleAnimation->setDisable()
        idleAnimation->keepOnDisabled()

        // Attack
        var allSeq: Sequence? = new Sequence()
        var seq3: Animation? = new Animation()
        for i in range(8, 12)
            seq3->addFrame(new AnimFrame(ARMY03, 0.1f, float4(60.0f * float(i % 4), 100.0f * float(i / 4), 60.0f, 100.0f)))
        for i in range(12, 14)
            seq3->addFrame(new AnimFrame(ARMY03, 0.1f, float4(60.0f * float(i % 4), 100.0f * float(i / 4), 60.0f, 100.0f)))
        allSeq->addAction(seq3)

        var allSeq2: Sequence? = new Sequence()
        allSeq2->addAction(new Wait(4.0f * 0.1f))

        var dam: FuncCallStored? = new FuncCallStored(1)
        allSeq2->addAction(dam)
        allSeq2->addAction(new Wait(2.0f * 0.1f))
        var dam2: FuncCallStored? = new FuncCallStored(2)
        allSeq2->addAction(dam2)

        var par: Parallel? = new Parallel()
        par->addAction(allSeq)
        par->addAction(allSeq2)

        attackAnimation = par
        attackAnimation->setDisable()
        attackAnimation->keepOnDisabled()

class Army04Chileg: Army
    def finalize
        for action in actionLists
            unsafe
                delete action
        unsafe
            delete idleAnimation
        unsafe
            delete moveAnimation
        unsafe
            delete attackAnimation
        unsafe
            delete dieAnimation
        unsafe
            delete takeDamageAnimation
        unsafe
            pass // delete image

    def Army04Chileg(_level: LevelScene?)
        // Initialize sprite
        Sprite`Sprite(self, ARMY04, float4(0.0f, 0.0f, 240.0f, 240.0f))
        setAnchor(0.25f, 1.0f)
        Army`Army(self, _level, CharacterCode A04_TREE, AttackType AREA, 10, 30.0f, 1, 2.0f, 160.0f, -30.0f, 180.0f, -30.0f)

        // Animation
        // Move
        var seq: Animation? = new Animation()
        for i in range(0, 4)
            seq->addFrame(new AnimFrame(ARMY04, 0.2f, float4(240.0f * float(i % 4), 240.0f * float(i / 4), 240.0f, 240.0f)))
        moveAnimation = new RepeatForever(seq)
        moveAnimation->setDisable()
        moveAnimation->keepOnDisabled()

        // Idle
        var seq2: Animation? = new Animation()
        for i in range(4, 8)
            seq2->addFrame(new AnimFrame(ARMY04, 0.2f, float4(240.0f * float(i % 4), 240.0f * float(i / 4), 240.0f, 240.0f)))
        idleAnimation = new RepeatForever(seq2)
        idleAnimation->setDisable()
        idleAnimation->keepOnDisabled()

        // Attack
        var allSeq: Sequence? = new Sequence()
        var seq3: Animation? = new Animation()
        for i in range(8, 13)
            seq3->addFrame(new AnimFrame(ARMY04, 0.075f, float4(240.0f * float(i % 4), 240.0f * float(i / 4), 240.0f, 240.0f)))
        for i in range(13, 16)
            seq3->addFrame(new AnimFrame(ARMY04, 0.075f, float4(240.0f * float(i % 4), 240.0f * float(i / 4), 240.0f, 240.0f)))
        allSeq->addAction(seq3)

        var allSeq2: Sequence? = new Sequence()
        allSeq2->addAction(new Wait(5.0f * 0.075f))

        var dam: FuncCallStored? = new FuncCallStored(1)
        allSeq2->addAction(dam)
        allSeq2->addAction(new Wait(3.0f * 0.075f))
        var dam2: FuncCallStored? = new FuncCallStored(2)
        allSeq2->addAction(dam2)

        var par: Parallel? = new Parallel()
        par->addAction(allSeq)
        par->addAction(allSeq2)

        attackAnimation = par
        attackAnimation->setDisable()
        attackAnimation->keepOnDisabled()

class Army05Chibomb: Army
    def finalize
        for action in actionLists
            unsafe
                delete action
        unsafe
            delete idleAnimation
        unsafe
            delete moveAnimation
        unsafe
            delete attackAnimation
        unsafe
            delete dieAnimation
        unsafe
            delete takeDamageAnimation
        unsafe
            pass // delete image

    def Army05Chibomb(_level: LevelScene?)
        // Initialize sprite
        Sprite`Sprite(self, ARMY05, float4(0.0f, 0.0f, 60.0f, 80.0f))
        setAnchor(1.0f, 1.0f)
        Army`Army(self, _level, CharacterCode A05_BOMB, AttackType AREA, 1, 100.0f, 50, 0.5f, 0.0f, -30.0f, 60.0f, -60.0f)

        // Animation
        // Move
        var seq: Animation? = new Animation()
        for i in range(0, 4)
            seq->addFrame(new AnimFrame(ARMY05, 0.075f, float4(60.0f * float(i % 4), 80.0f * float(i / 4), 60.0f, 80.0f)))
        moveAnimation = new RepeatForever(seq)
        moveAnimation->setDisable()
        moveAnimation->keepOnDisabled()

        // Idle
        var seq2: Animation? = new Animation()
        for i in range(4, 8)
            seq2->addFrame(new AnimFrame(ARMY05, 0.075f, float4(60.0f * float(i % 4), 80.0f * float(i / 4), 60.0f, 80.0f)))
        idleAnimation = new RepeatForever(seq2)
        idleAnimation->setDisable()
        idleAnimation->keepOnDisabled()

        // Attack
        var dam: FuncCallStored? = new FuncCallStored(1)
        attackAnimation = dam
        attackAnimation->setDisable()
        attackAnimation->keepOnDisabled()

        // Die
        dieAnimation = new FuncCallStored(4)
        dieAnimation->setDisable()
        dieAnimation->keepOnDisabled()

    def override takeDamage(_dam: int): void
        damageEnemy()

    def override damageEnemy(): void
        Army`damageEnemy(self)
        hp = 0
        die()

    def override funcCallStored4()
        isRemoved = true
        var seq: Sequence? = new Sequence()
        seq->addAction(new FadeOut(0.0f))
        seq->addAction(new Wait(2.0f))
        seq->addAction(new Disappear())
        var tempNode: Node? = new Node()
        tempNode->addAction(seq)
        level->addChild(tempNode)
        tempNode->addAction(new Explosion(1.2f, float2(x, y - 40.0f), 60.0f, 50))

        getSoundPool()->playEffect(EXPLOSION_SOUND)

class Army06Chileghot: Army
    def finalize
        for action in actionLists
            unsafe
                delete action
        unsafe
            delete idleAnimation
        unsafe
            delete moveAnimation
        unsafe
            delete attackAnimation
        unsafe
            delete dieAnimation
        unsafe
            delete takeDamageAnimation
        unsafe
            pass // delete image

    def Army06Chileghot(_level: LevelScene?)
        // Initialize sprite
        Sprite`Sprite(self, ARMY06, float4(0.0f, 0.0f, 240.0f, 240.0f))
        setAnchor(0.25f, 1.0f)
        Army`Army(self, _level, CharacterCode A06_FIRETREE, AttackType AREA, 10, 35.0f, 1, 1.4f, 160.0f, -30.0f, 180.0f, -30.0f)

        // Animation
        // Move
        var seq: Animation? = new Animation()
        for i in range(0, 4)
            seq->addFrame(new AnimFrame(ARMY06, 0.15f, float4(240.0f * float(i % 4), 240.0f * float(i / 4), 240.0f, 240.0f)))
        moveAnimation = new RepeatForever(seq)
        moveAnimation->setDisable()
        moveAnimation->keepOnDisabled()

        // Idle
        var seq2: Animation? = new Animation()
        for i in range(4, 8)
            seq2->addFrame(new AnimFrame(ARMY06, 0.15f, float4(240.0f * float(i % 4), 240.0f * float(i / 4), 240.0f, 240.0f)))
        idleAnimation = new RepeatForever(seq2)
        idleAnimation->setDisable()
        idleAnimation->keepOnDisabled()

        // Attack
        var allSeq: Sequence? = new Sequence()
        var seq3: Animation? = new Animation()
        for i in range(8, 13)
            seq3->addFrame(new AnimFrame(ARMY06, 0.075f, float4(240.0f * float(i % 4), 240.0f * float(i / 4), 240.0f, 240.0f)))
        for i in range(13, 16)
            seq3->addFrame(new AnimFrame(ARMY06, 0.075f, float4(240.0f * float(i % 4), 240.0f * float(i / 4), 240.0f, 240.0f)))
        allSeq->addAction(seq3)

        var allSeq2: Sequence? = new Sequence()
        allSeq2->addAction(new Wait(5.0f * 0.075f))

        var dam: FuncCallStored? = new FuncCallStored(1)
        allSeq2->addAction(dam)
        allSeq2->addAction(new Wait(3.0f * 0.075f))
        var dam2: FuncCallStored? = new FuncCallStored(2)
        allSeq2->addAction(dam2)

        var par: Parallel? = new Parallel()
        par->addAction(allSeq)
        par->addAction(allSeq2)

        attackAnimation = par
        attackAnimation->setDisable()
        attackAnimation->keepOnDisabled()

class Army07Chilegcold: Army
    def finalize
        for action in actionLists
            unsafe
                delete action
        unsafe
            delete idleAnimation
        unsafe
            delete moveAnimation
        unsafe
            delete attackAnimation
        unsafe
            delete dieAnimation
        unsafe
            delete takeDamageAnimation
        unsafe
            pass // delete image

    def Army07Chilegcold(_level: LevelScene?)
        // Initialize sprite
        Sprite`Sprite(self, ARMY07, float4(0.0f, 0.0f, 240.0f, 240.0f))
        setAnchor(0.25f, 1.0f)
        Army`Army(self, _level, CharacterCode A07_ICETREE, AttackType SINGLE, 120, 20.0f, 1, 4.0f, 0.0f, -30.0f, 0.0f, -30.0f)

        // Animation
        // Move
        var seq: Animation? = new Animation()
        for i in range(0, 4)
            seq->addFrame(new AnimFrame(ARMY07, 0.2f, float4(240.0f * float(i % 4), 240.0f * float(i / 4), 240.0f, 240.0f)))
        moveAnimation = new RepeatForever(seq)
        moveAnimation->setDisable()
        moveAnimation->keepOnDisabled()

        // Idle
        var seq2: Animation? = new Animation()
        for i in range(4, 8)
            seq2->addFrame(new AnimFrame(ARMY07, 0.2f, float4(240.0f * float(i % 4), 240.0f * float(i / 4), 240.0f, 240.0f)))
        idleAnimation = new RepeatForever(seq2)
        idleAnimation->setDisable()
        idleAnimation->keepOnDisabled()

        // Attack
        var allSeq: Sequence? = new Sequence()
        var seq3: Animation? = new Animation()
        for i in range(8, 10)
            seq3->addFrame(new AnimFrame(ARMY07, 0.15f, float4(240.0f * float(i % 4), 240.0f * float(i / 4), 240.0f, 240.0f)))
        for i in range(10, 11)
            seq3->addFrame(new AnimFrame(ARMY07, 0.15f, float4(240.0f * float(i % 4), 240.0f * float(i / 4), 240.0f, 240.0f)))
        allSeq->addAction(seq3)

        var allSeq2: Sequence? = new Sequence()
        allSeq2->addAction(new Wait(2.0f * 0.15f))

        var dam: FuncCallStored? = new FuncCallStored(1)
        allSeq2->addAction(dam)
        allSeq2->addAction(new Wait(1.0f * 0.15f))
        var dam2: FuncCallStored? = new FuncCallStored(2)
        allSeq2->addAction(dam2)

        var par: Parallel? = new Parallel()
        par->addAction(allSeq)
        par->addAction(allSeq2)

        attackAnimation = par
        attackAnimation->setDisable()
        attackAnimation->keepOnDisabled()

/*
=======================================================================================
EGG DEFINITIONS
=======================================================================================
*/
class Egg: Character
    changeTable: table<int; int>

    def finalize
        for action in actionLists
            unsafe
                delete action
        unsafe
            delete idleAnimation
        unsafe
            delete moveAnimation
        unsafe
            delete attackAnimation
        unsafe
            delete dieAnimation
        unsafe
            delete takeDamageAnimation
        unsafe
            pass // delete image

    def Egg(_level: LevelScene?; _charCode: CharacterCode; _speed: float)
        // Sprite
        setAnchor(1.0f, 1.0f)
        setPosition(LINE_START, LINE_GROUND)
        
        // Parameters
        level = _level
        charCode = _charCode
        hp = 1
        speed = _speed
        noticeFront = 0.0f
        noticeBack = -30.0f

    def changeArmyAtIndex(index: int): void
        var oldX: float = level.armyList[index].x
        var oldY: float = level.armyList[index].y
        find(changeTable, int(level.armyList[index].charCode)) <| $ (var code: int? const)
            if code != null
                level.armyList[index]->removeFromScene()
                var newArmy: Character? = createCharacter(level, *code)
                newArmy->setPosition(oldX, oldY)
                level->addChild(newArmy)
                level.armyList[index] = newArmy

    def override updateLogicPerCs(): void
        // Check for army
        var minDelta: float = 0.0f
        var index: int = -1
        var i: int = 0
        while i < level.armyList |> length()
            var delta = level.armyList[i].x - x
            if delta >= noticeBack && delta <= noticeFront && level.armyList[i].charCode != CharacterCode A00_BASE
                if index == -1
                    index := i
                    minDelta = delta
                elif minDelta > delta
                    index := i
                    minDelta = delta
            i++
        if index != -1
            changeArmyAtIndex(index)
            die()
            return

        // Change position when moving
        if !isDead()
            x = min(x + speed * CENTISEC, LINE_END)
            if x >= LINE_END
                die()

    def override die(): void
        hp = 0
        var disa: Disappear? = new Disappear()
        addAction(disa)

    def override move(): void
        charState = CharacterState MOVING
        animateMove()

    def override animateMove(): void
        moveAnimation->reset()
        addAction(moveAnimation)

class Egg01Fire: Egg
    def finalize
        for action in actionLists
            unsafe
                delete action
        unsafe
            delete idleAnimation
        unsafe
            delete moveAnimation
        unsafe
            delete attackAnimation
        unsafe
            delete dieAnimation
        unsafe
            delete takeDamageAnimation
        unsafe
            pass // delete image

    def Egg01Fire(_level: LevelScene?)
        // Initialize sprite
        Sprite`Sprite(self, EGG01, float4(0.0f, 0.0f, 40.0f, 60.0f))
        Egg`Egg(self, _level, CharacterCode B01_FIRE, 100.0f)

        // Correspondence table
        changeTable <- {{ 001 => 002; 003 => 001; 004 => 006; 007 => 004 }}

        // Animation
        var seq: Animation? = new Animation()
        for i in range(0, 4)
            seq->addFrame(new AnimFrame(EGG01, 0.1f, float4(40.0f * float(i % 4), 60.0f * float(i / 4), 40.0f, 60.0f)))
        moveAnimation = new RepeatForever(seq)
        addAction(moveAnimation)

    def override die(): void
        hp = 0
        var seq: Sequence? = new Sequence()
        seq->addAction(new FadeOut(0.0f))
        seq->addAction(new Wait(1.5f))
        seq->addAction(new Disappear())
        var tempNode: Node? = new Node()
        tempNode->addAction(seq)
        level->addChild(tempNode)
        addAction(new Disappear())
        tempNode->addAction(new Eruption(1.5f, -250.0f, float2(x, y), 20.0f, 150.0f, 40))
        getSoundPool()->playEffect(FIRE_SOUND)

class Egg02Ice: Egg
    def finalize
        for action in actionLists
            unsafe
                delete action
        unsafe
            delete idleAnimation
        unsafe
            delete moveAnimation
        unsafe
            delete attackAnimation
        unsafe
            delete dieAnimation
        unsafe
            delete takeDamageAnimation
        unsafe
            pass // delete image

    def Egg02Ice(_level: LevelScene?)
        // Initialize sprite
        Sprite`Sprite(self, EGG02, float4(0.0f, 0.0f, 40.0f, 60.0f))
        Egg`Egg(self, _level, CharacterCode B02_ICE, 80.0f)

        // Correspondence table
        changeTable <- {{ 001 => 003; 002 => 001; 004 => 007; 006 => 004 }}

        // Animation
        var seq: Animation? = new Animation()
        for i in range(0, 4)
            seq->addFrame(new AnimFrame(EGG02, 0.12f, float4(40.0f * float(i % 4), 60.0f * float(i / 4), 40.0f, 60.0f)))
        moveAnimation = new RepeatForever(seq)
        addAction(moveAnimation)

    def override die(): void
        hp = 0
        var seq: Sequence? = new Sequence()
        seq->addAction(new FadeOut(0.0f))
        seq->addAction(new Wait(2.0f))
        seq->addAction(new Disappear())
        var tempNode: Node? = new Node()
        tempNode->addAction(seq)
        level->addChild(tempNode)
        addAction(new Disappear())
        tempNode->addAction(new Blizzard(2.0f, -250.0f, float2(x, y), 20.0f, 100.0f, 40))

        getSoundPool()->playEffect(ICE_SOUND)

class Egg03Seed: Egg
    def finalize
        for action in actionLists
            unsafe
                delete action
        unsafe
            delete idleAnimation
        unsafe
            delete moveAnimation
        unsafe
            delete attackAnimation
        unsafe
            delete dieAnimation
        unsafe
            delete takeDamageAnimation
        unsafe
            pass // delete image

    def Egg03Seed(_level: LevelScene?)
        // Initialize sprite
        Sprite`Sprite(self, EGG03, float4(0.0f, 0.0f, 40.0f, 60.0f))
        Egg`Egg(self, _level, CharacterCode B03_TREE, 90.0f)

        // Correspondence table
        changeTable <- {{ 001 => 004; 002 => 006; 003 => 007}}

        // Animation
        var seq: Animation? = new Animation()
        for i in range(0, 8)
            seq->addFrame(new AnimFrame(EGG03, 0.075f, float4(40.0f * float(i % 4), 60.0f * float(i / 4), 40.0f, 60.0f)))
        moveAnimation = new RepeatForever(seq)
        addAction(moveAnimation)

    def override die(): void
        hp = 0
        var seq: Sequence? = new Sequence()
        seq->addAction(new FadeOut(0.0f))
        seq->addAction(new Wait(2.0f))
        seq->addAction(new Disappear())
        var tempNode: Node? = new Node()
        tempNode->addAction(seq)
        level->addChild(tempNode)
        addAction(new Disappear())
        tempNode->addAction(new LeafStorm(2.0f, -350.0f, float2(x, y), 20.0f, 100.0f, 25))

        getSoundPool()->playEffect(SEED_SOUND)
        
/*
=======================================================================================
ENEMY DEFINITIONS
=======================================================================================
*/
class Enemy: Character
    def finalize
        for action in actionLists
            unsafe
                delete action
        unsafe
            delete idleAnimation
        unsafe
            delete moveAnimation
        unsafe
            delete attackAnimation
        unsafe
            delete dieAnimation
        unsafe
            delete takeDamageAnimation
        unsafe
            pass // delete image

    def Enemy(_level: LevelScene?; _charCode: CharacterCode; _attackType: AttackType; _hp: int; _speed: float; _damage: int; _idleInterval: float; _noticeFront: float; _noticeBack: float; _rangeFront: float; _rangeBack: float)
        // Sprite
        setPosition(LINE_START, LINE_GROUND)
        
        // Parameters
        level = _level
        charCode = _charCode
        attackType = _attackType
        hp = _hp
        speed = _speed
        damage = _damage
        idleInterval = _idleInterval
        noticeFront = _noticeFront
        noticeBack = _noticeBack
        rangeFront = _rangeFront
        rangeBack = _rangeBack

        // Animation
        // Take damage
        var seq: Sequence? = new Sequence()
        seq->addAction(new TintTo(0xff7070, 0.0f))
        seq->addAction(new Wait(0.1f))
        seq->addAction(new TintTo(0xffffff, 0.0f))
        seq->setDisable()
        takeDamageAnimation = seq
        takeDamageAnimation->keepOnDisabled()

        // Die
        var seq2: Sequence? = new Sequence()
        seq2->addAction(new JumpBy(float2(JUMP_DIE_DELTA_X, JUMP_DIE_DELTA_Y), JUMP_DIE_HEIGHT, JUMP_DIE_INTERVAL))
        seq2->addAction(new Disappear())
        seq2->setDisable()
        dieAnimation = seq2
        dieAnimation->keepOnDisabled()

    def checkHasArmy(): bool
        for army in level.armyList
            var delta = x - army.x
            if delta >= noticeBack && delta <= noticeFront
                return true
        return false

    def damageArmy(): void
        if attackType == AttackType AREA
            for army in level.armyList
                var delta = x - army.x
                if delta >= rangeBack && delta <= rangeFront
                    army->takeDamage(damage)
        else
            var minDelta: float = 0.0f
            var target: Character? = null
            for army in level.armyList
                var delta = x - army.x
                if delta >= rangeBack && delta <= rangeFront
                    if target == null
                        target = army
                        minDelta = delta
                    elif minDelta > delta
                        target = army
                        minDelta = delta
            if target != null
                target->takeDamage(damage)

    def override updateLogicPerCs(): void
        if !isDead()
            var hasEnemy: bool = checkHasArmy()

            // Change state
            // Idle --> Move
            if !hasEnemy && charState == CharacterState IDLING
                move()
            
            // Idle --> Idle
            if idleTimer > 0.0f && hasEnemy && charState == CharacterState IDLING
                idleTimer = idleTimer - CENTISEC

            // Idle --> Attack
            if idleTimer <= 0.0f && hasEnemy && charState == CharacterState IDLING
                attack()

            // Move --> Idle
            if idleTimer > 0.0f && hasEnemy && charState == CharacterState MOVING
                idleTimer = idleTimer - CENTISEC
                idle()

            // Move --> Attack
            if idleTimer <= 0.0f && hasEnemy && charState == CharacterState MOVING
                attack()

            // Change position when moving
            if !isDead() && charState == CharacterState MOVING
                x = max(x - speed * CENTISEC, LINE_START)

    def override idle(): void
        charState = CharacterState IDLING
        idleTimer = idleInterval
        animateIdle()

    def override animateIdle(): void
        moveAnimation->setDisable()
        attackAnimation->setDisable()
        idleAnimation->reset()
        addAction(idleAnimation)

    def override move(): void
        charState = CharacterState MOVING
        animateMove()

    def override animateMove(): void
        moveAnimation->reset()
        attackAnimation->setDisable()
        idleAnimation->setDisable()
        addAction(moveAnimation)

    def override attack(): void
        charState = CharacterState ATTACKING
        animateAttack()

    def override animateAttack(): void
        moveAnimation->setDisable()
        attackAnimation->reset()
        idleAnimation->setDisable()
        addAction(attackAnimation)

    def override funcCallStored1(): void
        damageArmy()

    def override funcCallStored2(): void
        idle()

class Enemy01Mouse: Enemy
    def finalize
        for action in actionLists
            unsafe
                delete action
        unsafe
            delete idleAnimation
        unsafe
            delete moveAnimation
        unsafe
            delete attackAnimation
        unsafe
            delete dieAnimation
        unsafe
            delete takeDamageAnimation
        unsafe
            pass // delete image

    def Enemy01Mouse(_level: LevelScene?)
        // Initialize sprite
        Sprite`Sprite(self, ENEMY01, float4(0.0f, 0.0f, 60.0f, 80.0f))
        setAnchor(0.0f, 1.0f)
        Enemy`Enemy(self, _level, CharacterCode E01_NORMAL, AttackType SINGLE, 10, 30.0f, 1, 1.0f, 5.0f, -30.0f, 5.0f, -30.0f)

        // Animation
        // Move
        var seq: Animation? = new Animation()
        for i in range(0, 4)
            seq->addFrame(new AnimFrame(ENEMY01, 0.2f, float4(60.0f * float(i % 4), 80.0f * float(i / 4), 60.0f, 80.0f)))
        moveAnimation = new RepeatForever(seq)
        moveAnimation->setDisable()
        moveAnimation->keepOnDisabled()

        // Idle
        var seq2: Animation? = new Animation()
        for i in range(4, 8)
            seq2->addFrame(new AnimFrame(ENEMY01, 0.2f, float4(60.0f * float(i % 4), 80.0f * float(i / 4), 60.0f, 80.0f)))
        idleAnimation = new RepeatForever(seq2)
        idleAnimation->setDisable()
        idleAnimation->keepOnDisabled()

        // Attack
        var allSeq: Sequence? = new Sequence()
        var seq3: Animation? = new Animation()
        for i in range(8, 13)
            seq3->addFrame(new AnimFrame(ENEMY01, 0.075f, float4(60.0f * float(i % 4), 80.0f * float(i / 4), 60.0f, 80.0f)))
        allSeq->addAction(seq3)

        var dam: FuncCallStored? = new FuncCallStored(1)
        allSeq->addAction(dam)

        var seq4: Animation? = new Animation()
        for i in range(13, 15)
            seq4->addFrame(new AnimFrame(ENEMY01, 0.1f, float4(60.0f * float(i % 4), 80.0f * float(i / 4), 60.0f, 80.0f)))
        allSeq->addAction(seq4)

        var dam2: FuncCallStored? = new FuncCallStored(2)
        allSeq->addAction(dam2)

        attackAnimation = allSeq
        attackAnimation->setDisable()
        attackAnimation->keepOnDisabled()

class Enemy02Moucat: Enemy
    def finalize
        for action in actionLists
            unsafe
                delete action
        unsafe
            delete idleAnimation
        unsafe
            delete moveAnimation
        unsafe
            delete attackAnimation
        unsafe
            delete dieAnimation
        unsafe
            delete takeDamageAnimation
        unsafe
            pass // delete image

    def Enemy02Moucat(_level: LevelScene?)
        // Initialize sprite
        Sprite`Sprite(self, ENEMY02, float4(0.0f, 0.0f, 76.0f, 80.0f))
        setAnchor(0.0f, 1.0f)
        Enemy`Enemy(self, _level, CharacterCode E02_CAT, AttackType SINGLE, 20, 30.0f, 2, 1.0f, 5.0f, -30.0f, 5.0f, -30.0f)

        // Animation
        // Move
        var seq: Animation? = new Animation()
        for i in range(0, 4)
            seq->addFrame(new AnimFrame(ENEMY02, 0.2f, float4(76.0f * float(i % 4), 80.0f * float(i / 4), 76.0f, 80.0f)))
        moveAnimation = new RepeatForever(seq)
        moveAnimation->setDisable()
        moveAnimation->keepOnDisabled()

        // Idle
        var seq2: Animation? = new Animation()
        for i in range(4, 8)
            seq2->addFrame(new AnimFrame(ENEMY02, 0.2f, float4(76.0f * float(i % 4), 80.0f * float(i / 4), 76.0f, 80.0f)))
        idleAnimation = new RepeatForever(seq2)
        idleAnimation->setDisable()
        idleAnimation->keepOnDisabled()

        // Attack
        var allSeq: Sequence? = new Sequence()
        var seq3: Animation? = new Animation()
        for i in range(8, 13)
            seq3->addFrame(new AnimFrame(ENEMY02, 0.075f, float4(76.0f * float(i % 4), 80.0f * float(i / 4), 76.0f, 80.0f)))
        allSeq->addAction(seq3)

        var dam: FuncCallStored? = new FuncCallStored(1)
        allSeq->addAction(dam)

        var seq4: Animation? = new Animation()
        for i in range(13, 15)
            seq4->addFrame(new AnimFrame(ENEMY02, 0.1f, float4(76.0f * float(i % 4), 80.0f * float(i / 4), 76.0f, 80.0f)))
        allSeq->addAction(seq4)

        var dam2: FuncCallStored? = new FuncCallStored(2)
        allSeq->addAction(dam2)

        attackAnimation = allSeq
        attackAnimation->setDisable()
        attackAnimation->keepOnDisabled()

class Enemy03Moubird: Enemy
    def finalize
        for action in actionLists
            unsafe
                delete action
        unsafe
            delete idleAnimation
        unsafe
            delete moveAnimation
        unsafe
            delete attackAnimation
        unsafe
            delete dieAnimation
        unsafe
            delete takeDamageAnimation
        unsafe
            pass // delete image

    def Enemy03Moubird(_level: LevelScene?)
        // Initialize sprite
        Sprite`Sprite(self, ENEMY03, float4(0.0f, 0.0f, 76.0f, 136.0f))
        setAnchor(0.289f, 1.0f)
        Enemy`Enemy(self, _level, CharacterCode E03_BIRD, AttackType AREA, 20, 40.0f, 10, 4.5f, 0.0f, -30.0f, 4.0f, -30.0f)

        // Animation
        // Move
        var seq: Animation? = new Animation()
        for i in range(0, 4)
            seq->addFrame(new AnimFrame(ENEMY03, 0.2f, float4(76.0f * float(i % 4), 136.0f * float(i / 4), 76.0f, 136.0f)))
        moveAnimation = new RepeatForever(seq)
        moveAnimation->setDisable()
        moveAnimation->keepOnDisabled()

        // Idle
        var seq2: Animation? = new Animation()
        for i in range(4, 8)
            seq2->addFrame(new AnimFrame(ENEMY03, 0.2f, float4(76.0f * float(i % 4), 136.0f * float(i / 4), 76.0f, 136.0f)))
        idleAnimation = new RepeatForever(seq2)
        idleAnimation->setDisable()
        idleAnimation->keepOnDisabled()

        // Attack
        var allSeq: Sequence? = new Sequence()
        var seq3: Animation? = new Animation()
        for i in range(8, 13)
            seq3->addFrame(new AnimFrame(ENEMY03, 0.05f, float4(76.0f * float(i % 4), 136.0f * float(i / 4), 76.0f, 136.0f)))
        for i in range(13, 20)
            seq3->addFrame(new AnimFrame(ENEMY03, 0.1f, float4(76.0f * float(i % 4), 136.0f * float(i / 4), 76.0f, 136.0f)))
        allSeq->addAction(seq3)

        var allSeq2: Sequence? = new Sequence()
        allSeq2->addAction(new Wait(5.0f * 0.05f))

        var dam: FuncCallStored? = new FuncCallStored(1)
        allSeq2->addAction(dam)
        allSeq2->addAction(new Wait(7.0f * 0.1f))
        var dam2: FuncCallStored? = new FuncCallStored(2)
        allSeq2->addAction(dam2)

        var par: Parallel? = new Parallel()
        par->addAction(allSeq)
        par->addAction(allSeq2)

        attackAnimation = par
        attackAnimation->setDisable()
        attackAnimation->keepOnDisabled()

class Enemy04Moucroco: Enemy
    def finalize
        for action in actionLists
            unsafe
                delete action
        unsafe
            delete idleAnimation
        unsafe
            delete moveAnimation
        unsafe
            delete attackAnimation
        unsafe
            delete dieAnimation
        unsafe
            delete takeDamageAnimation
        unsafe
            pass // delete image

    def Enemy04Moucroco(_level: LevelScene?)
        // Initialize sprite
        Sprite`Sprite(self, ENEMY04, float4(0.0f, 0.0f, 84.0f, 80.0f))
        setAnchor(0.1f, 1.0f)
        Enemy`Enemy(self, _level, CharacterCode E04_CROCO, AttackType AREA, 50, 15.0f, 30, 0.5f, 0.0f, -30.0f, 1.0f, -30.0f)

        // Animation
        // Move
        var seq: Animation? = new Animation()
        for i in range(0, 4)
            seq->addFrame(new AnimFrame(ENEMY04, 0.3f, float4(84.0f * float(i % 4), 80.0f * float(i / 4), 84.0f, 80.0f)))
        moveAnimation = new RepeatForever(seq)
        moveAnimation->setDisable()
        moveAnimation->keepOnDisabled()

        // Idle
        var seq2: Animation? = new Animation()
        for i in range(4, 8)
            seq2->addFrame(new AnimFrame(ENEMY04, 0.3f, float4(84.0f * float(i % 4), 80.0f * float(i / 4), 84.0f, 80.0f)))
        idleAnimation = new RepeatForever(seq2)
        idleAnimation->setDisable()
        idleAnimation->keepOnDisabled()

        // Attack
        var allSeq: Sequence? = new Sequence()
        var seq3: Animation? = new Animation()
        for i in range(8, 14)
            seq3->addFrame(new AnimFrame(ENEMY04, 0.1f, float4(84.0f * float(i % 4), 80.0f * float(i / 4), 84.0f, 80.0f)))
        for i in range(14, 17)
            seq3->addFrame(new AnimFrame(ENEMY04, 0.1f, float4(84.0f * float(i % 4), 80.0f * float(i / 4), 84.0f, 80.0f)))
        allSeq->addAction(seq3)

        var allSeq2: Sequence? = new Sequence()
        allSeq2->addAction(new Wait(6.0f * 0.1f))

        var dam: FuncCallStored? = new FuncCallStored(1)
        allSeq2->addAction(dam)
        allSeq2->addAction(new Wait(3.0f * 0.1f))
        var dam2: FuncCallStored? = new FuncCallStored(2)
        allSeq2->addAction(dam2)

        var par: Parallel? = new Parallel()
        par->addAction(allSeq)
        par->addAction(allSeq2)

        attackAnimation = par
        attackAnimation->setDisable()
        attackAnimation->keepOnDisabled()

class Enemy05Mouphant: Enemy
    def finalize
        for action in actionLists
            unsafe
                delete action
        unsafe
            delete idleAnimation
        unsafe
            delete moveAnimation
        unsafe
            delete attackAnimation
        unsafe
            delete dieAnimation
        unsafe
            delete takeDamageAnimation
        unsafe
            pass // delete image

    def Enemy05Mouphant(_level: LevelScene?)
        // Initialize sprite
        Sprite`Sprite(self, ENEMY05, float4(0.0f, 0.0f, 360.0f, 180.0f))
        setAnchor(0.334f, 1.0f)
        Enemy`Enemy(self, _level, CharacterCode E05_ELEPHANT, AttackType AREA, 150, 10.0f, 30, 4.0f, 120.0f, -30.0f, 120.0f, -30.0f)

        // Animation
        // Move
        var seq: Animation? = new Animation()
        for i in range(0, 4)
            seq->addFrame(new AnimFrame(ENEMY05, 0.1f, float4(360.0f * float(i % 4), 180.0f * float(i / 4), 360.0f, 180.0f)))
        moveAnimation = new RepeatForever(seq)
        moveAnimation->setDisable()
        moveAnimation->keepOnDisabled()

        // Idle
        var seq2: Animation? = new Animation()
        for i in range(0, 4)
            seq2->addFrame(new AnimFrame(ENEMY05, 0.3f, float4(360.0f * float(i % 4), 180.0f * float(i / 4), 360.0f, 180.0f)))
        idleAnimation = new RepeatForever(seq2)
        idleAnimation->setDisable()
        idleAnimation->keepOnDisabled()

        // Attack
        var allSeq: Sequence? = new Sequence()
        var seq3: Animation? = new Animation()
        for i in range(8, 16)
            seq3->addFrame(new AnimFrame(ENEMY05, 0.05f, float4(360.0f * float(i % 4), 180.0f * float(i / 4), 360.0f, 180.0f)))
        for i in range(16, 25)
            seq3->addFrame(new AnimFrame(ENEMY05, 0.1f, float4(360.0f * float(i % 4), 180.0f * float(i / 4), 360.0f, 180.0f)))
        allSeq->addAction(seq3)

        var allSeq2: Sequence? = new Sequence()
        allSeq2->addAction(new Wait(8.0f * 0.05f))

        var dam: FuncCallStored? = new FuncCallStored(1)
        allSeq2->addAction(dam)
        allSeq2->addAction(new Wait(9.0f * 0.1f))
        var dam2: FuncCallStored? = new FuncCallStored(2)
        allSeq2->addAction(dam2)

        var par: Parallel? = new Parallel()
        par->addAction(allSeq)
        par->addAction(allSeq2)

        attackAnimation = par
        attackAnimation->setDisable()
        attackAnimation->keepOnDisabled()

def createCharacter(level: LevelScene?; intcharcode: int): Character?
    if intcharcode == int(CharacterCode A01_NORMAL)
        return new Army01Chica(level)
    elif intcharcode == int(CharacterCode A02_FIRE)
        return new Army02Chiburn(level)
    elif intcharcode == int(CharacterCode A03_ICE)
        return new Army03Chirystal(level)
    elif intcharcode == int(CharacterCode A04_TREE)
        return new Army04Chileg(level)
    elif intcharcode == int(CharacterCode A05_BOMB)
        return new Army05Chibomb(level)
    elif intcharcode == int(CharacterCode A06_FIRETREE)
        return new Army06Chileghot(level)
    elif intcharcode == int(CharacterCode A07_ICETREE)
        return new Army07Chilegcold(level)
    elif intcharcode == int(CharacterCode B01_FIRE)
        return new Egg01Fire(level)
    elif intcharcode == int(CharacterCode B02_ICE)
        return new Egg02Ice(level)
    elif intcharcode == int(CharacterCode B03_TREE)
        return new Egg03Seed(level)
    elif intcharcode == int(CharacterCode E01_NORMAL)
        return new Enemy01Mouse(level)
    elif intcharcode == int(CharacterCode E02_CAT)
        return new Enemy02Moucat(level)
    elif intcharcode == int(CharacterCode E03_BIRD)
        return new Enemy03Moubird(level)
    elif intcharcode == int(CharacterCode E04_CROCO)
        return new Enemy04Moucroco(level)
    elif intcharcode == int(CharacterCode E05_ELEPHANT)
        return new Enemy05Mouphant(level)
    return null