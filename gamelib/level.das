require pentwin/scene
require pentwin/node
require pentwin/sprite
require pentwin/utils
require math
require constant
require effect

module level public

var erhh: float = 0.0f

class LevelScene: Scene
    timer: float = 0.0f
    countTimer: int = 0 // number of centisecs
    isPaused: bool = false

    worker: int = 0

    armyBase: ArmyBase?
    enemyBase: EnemyBase?

    armyList: array<Character?>
    eggList: array<Character?>
    enemyList: array<Character?>

    workerList: array<Sprite?>
    
    def finalize
        pass

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
        armyBase = new ArmyBase(unsafe(addr(self)), 10)
        addChild(armyBase)
        armyList |> push(armyBase)
        
        enemyBase = new EnemyBase(unsafe(addr(self)), 10)
        addChild(enemyBase)
        enemyList |> push(enemyBase)

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

    def override initialize(): void
        // Draw backgrounds
        drawBackground()

        // Initialize bases
        initializeBases()

        // Initialize workers
        initializeWorkers()

        // Test
        addArmy(createCharacter(unsafe(addr(self)), 002))
        // addArmy(new Army07Chilegcold(unsafe(addr(self))))
        
        addEnemy(new Enemy03Moubird(unsafe(addr(self))))
        addEnemy(createCharacter(unsafe(addr(self)), 204))
        addEnemy(new Enemy05Mouphant(unsafe(addr(self))))

    def override update(dt: float): void
        if !isPaused
            timer = timer + dt
            while timer >= CENTISEC
                timer -= CENTISEC
                updateLogicPerCs()
        Scene`update(self, dt)

    def updateLogicPerCs(): void
        countTimer++
        if countTimer == 500
            addEgg(createCharacter(unsafe(addr(self)), 102))

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

    def isWinner(): bool
        return enemyBase->isDead()

    def win(): void
        pauseAllEvents()
        pauseAllActions()
        isPaused = true

    def isLoser(): bool
        return armyBase->isDead()

    def lose(): void
        pauseAllEvents()
        pauseAllActions()
        isPaused = true

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

    def finalize
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

    def updateLogicPerCs(): void
        pass

    def animateIdle(): void
        pass

    def animateMove(): void
        pass

    def animateAttack(): void
        pass

    def animateDie(): void
        pauseAllActions()
        dieAnimation->reset()
        addAction(dieAnimation)

    def animateTakeDamage(): void
        if takeDamageAnimation?.isDisabled ?? false
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
        animateTakeDamage()
        if isDead()
            die()

    def isDead(): bool
        return hp <= 0

class TowerBase: Character
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
        seq->addAction(new FadeOut(0.0f))
        seq->addAction(new Wait(5.0f))
        seq->addAction(new Disappear())
        var tempNode: Node? = new Node()
        tempNode->addAction(seq)
        level->addChild(tempNode)
        tempNode->addAction(new Explosion(5.0f, float2(x - 60.0f, y - 60.0f), 80.0f, 100))

class EnemyBase: TowerBase
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
        seq->addAction(new FadeOut(0.0f))
        seq->addAction(new Wait(5.0f))
        seq->addAction(new Disappear())
        var tempNode: Node? = new Node()
        tempNode->addAction(seq)
        level->addChild(tempNode)
        tempNode->addAction(new Explosion(5.0f, float2(x + 60.0f, y - 150.0f), 80.0f, 100))

/*
=======================================================================================
ARMY DEFINITIONS
=======================================================================================
*/
class Army: Character
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
    def Army01Chica(_level: LevelScene?)
        // Initialize sprite
        Sprite`Sprite(self, ARMY01, float4(0.0f, 0.0f, 60.0f, 80.0f))
        setAnchor(1.0f, 1.0f)
        Army`Army(self, _level, CharacterCode A01_NORMAL, AttackType SINGLE, 10, 40.0f, 1, 1.0f, 5.0f, -30.0f, 5.0f, -30.0f)

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
    def Army02Chiburn(_level: LevelScene?)
        // Initialize sprite
        Sprite`Sprite(self, ARMY02, float4(0.0f, 0.0f, 60.0f, 80.0f))
        setAnchor(1.0f, 1.0f)
        Army`Army(self, _level, CharacterCode A02_FIRE, AttackType SINGLE, 10, 60.0f, 1, 0.5f, 5.0f, -30.0f, 5.0f, -30.0f)

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
    def Army03Chirystal(_level: LevelScene?)
        // Initialize sprite
        Sprite`Sprite(self, ARMY03, float4(0.0f, 0.0f, 60.0f, 100.0f))
        setAnchor(1.0f, 1.0f)
        Army`Army(self, _level, CharacterCode A03_ICE, AttackType SINGLE, 30, 20.0f, 0, 0.5f, 0.0f, -30.0f, 0.0f, -30.0f)

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
    def Army04Chileg(_level: LevelScene?)
        // Initialize sprite
        Sprite`Sprite(self, ARMY04, float4(0.0f, 0.0f, 240.0f, 240.0f))
        setAnchor(0.25f, 1.0f)
        Army`Army(self, _level, CharacterCode A04_TREE, AttackType AREA, 15, 30.0f, 2, 4.0f, 170.0f, -30.0f, 180.0f, -30.0f)

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
    def Army05Chibomb(_level: LevelScene?)
        // Initialize sprite
        Sprite`Sprite(self, ARMY05, float4(0.0f, 0.0f, 60.0f, 80.0f))
        setAnchor(1.0f, 1.0f)
        Army`Army(self, _level, CharacterCode A05_BOMB, AttackType AREA, 1, 120.0f, 50, 0.5f, 0.0f, -30.0f, 60.0f, -60.0f)

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
        tempNode->addAction(new Explosion(0.5f, float2(x, y - 40.0f), 60.0f, 30))

class Army06Chileghot: Army
    def Army06Chileghot(_level: LevelScene?)
        // Initialize sprite
        Sprite`Sprite(self, ARMY06, float4(0.0f, 0.0f, 240.0f, 240.0f))
        setAnchor(0.25f, 1.0f)
        Army`Army(self, _level, CharacterCode A06_FIRETREE, AttackType AREA, 15, 40.0f, 4, 3.0f, 170.0f, -30.0f, 180.0f, -30.0f)

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
    def Army07Chilegcold(_level: LevelScene?)
        // Initialize sprite
        Sprite`Sprite(self, ARMY07, float4(0.0f, 0.0f, 240.0f, 240.0f))
        setAnchor(0.25f, 1.0f)
        Army`Army(self, _level, CharacterCode A07_ICETREE, AttackType AREA, 60, 20.0f, 0, 3.0f, 0.0f, -30.0f, 0.0f, -30.0f)

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
    def Egg01Fire(_level: LevelScene?)
        // Initialize sprite
        Sprite`Sprite(self, EGG01, float4(0.0f, 0.0f, 40.0f, 60.0f))
        Egg`Egg(self, _level, CharacterCode B01_FIRE, 150.0f)

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
        tempNode->addAction(new Eruption(1.5f, -250.0f, float2(x, y), 20.0f, 150.0f, 50))

class Egg02Ice: Egg
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
        tempNode->addAction(new Blizzard(2.0f, -250.0f, float2(x, y), 20.0f, 100.0f, 50))

class Egg03Seed: Egg
    def Egg03Seed(_level: LevelScene?)
        // Initialize sprite
        Sprite`Sprite(self, EGG03, float4(0.0f, 0.0f, 40.0f, 60.0f))
        Egg`Egg(self, _level, CharacterCode B03_TREE, 120.0f)

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
        tempNode->addAction(new LeafStorm(2.0f, -350.0f, float2(x, y), 20.0f, 100.0f, 50))
        
/*
=======================================================================================
ENEMY DEFINITIONS
=======================================================================================
*/
class Enemy: Character
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
    def Enemy01Mouse(_level: LevelScene?)
        // Initialize sprite
        Sprite`Sprite(self, ENEMY01, float4(0.0f, 0.0f, 60.0f, 80.0f))
        setAnchor(0.0f, 1.0f)
        Enemy`Enemy(self, _level, CharacterCode E01_NORMAL, AttackType SINGLE, 10, 40.0f, 1, 1.0f, 5.0f, -30.0f, 5.0f, -30.0f)

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
    def Enemy02Moucat(_level: LevelScene?)
        // Initialize sprite
        Sprite`Sprite(self, ENEMY02, float4(0.0f, 0.0f, 76.0f, 80.0f))
        setAnchor(0.0f, 1.0f)
        Enemy`Enemy(self, _level, CharacterCode E02_CAT, AttackType SINGLE, 20, 40.0f, 1, 1.0f, 5.0f, -30.0f, 5.0f, -30.0f)

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
    def Enemy03Moubird(_level: LevelScene?)
        // Initialize sprite
        Sprite`Sprite(self, ENEMY03, float4(0.0f, 0.0f, 76.0f, 136.0f))
        setAnchor(0.289f, 1.0f)
        Enemy`Enemy(self, _level, CharacterCode E03_BIRD, AttackType SINGLE, 15, 60.0f, 2, 1.0f, 0.0f, -30.0f, 0.0f, -30.0f)

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
    def Enemy04Moucroco(_level: LevelScene?)
        // Initialize sprite
        Sprite`Sprite(self, ENEMY04, float4(0.0f, 0.0f, 84.0f, 80.0f))
        setAnchor(0.1f, 1.0f)
        Enemy`Enemy(self, _level, CharacterCode E04_CROCO, AttackType AREA, 20, 20.0f, 5, 2.0f, 0.0f, -30.0f, 0.0f, -30.0f)

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
    def Enemy05Mouphant(_level: LevelScene?)
        // Initialize sprite
        Sprite`Sprite(self, ENEMY05, float4(0.0f, 0.0f, 360.0f, 180.0f))
        setAnchor(0.334f, 1.0f)
        Enemy`Enemy(self, _level, CharacterCode E05_ELEPHANT, AttackType AREA, 150, 20.0f, 30, 5.0f, 120.0f, -30.0f, 120.0f, -30.0f)

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