require pentwin/scene
require pentwin/node
require pentwin/sprite
require pentwin/utils
require constant

module level public

let shared private
    BACKDROP = "gamelib/assets/sprites/background/backdrop.png"
    GROUND = "gamelib/assets/sprites/background/ground.png"
    CLOUD = "gamelib/assets/sprites/background/cloud.png"
    MOUNTAIN = "gamelib/assets/sprites/background/mountain.png"
    TREE = "gamelib/assets/sprites/background/tree.png"
    ARMY_BASE = "gamelib/assets/sprites/tower/base.png"
    ENEMY_BASE = "gamelib/assets/sprites/tower/enemy.png"

class LevelScene: Scene
    timer: float = 0.0f
    isPaused: bool = false

    armyBase: ArmyBase?
    enemyBase: EnemyBase?

    armyList: array<Character?>
    enemyList: array<Character?>
    
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

    def override initialize(): void
        // Draw backgrounds
        drawBackground()

        // Initialize bases
        armyBase = new ArmyBase(unsafe(addr(self)), 50)
        addChild(armyBase)
        armyList |> push(armyBase)

        enemyBase = new EnemyBase(unsafe(addr(self)), 50)
        addChild(enemyBase)
        enemyList |> push(enemyBase)

    def override update(dt: float): void
        if !isPaused
            timer = timer + dt
            while timer >= CENTISEC
                timer -= CENTISEC
                updateLogicPerCs()
        Scene`update(self, dt)

    def updateLogicPerCs(): void
        pass

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

    def updateLogicPerCs(): void
        pass

    def animateIdle(): void
        pass

    def animateMove(): void
        pass

    def animateAttack(): void
        pass

    def animateDie(): void
        pass

    def animateTakeDamage(): void
        pass

    def idle(): void
        pass

    def move(): void
        pass

    def attack(): void
        pass

    def die(): void
        pass

    def takeDamage(_dam: int): void
        hp = hp - _dam
        animateTakeDamage()

    def isDead(): bool
        return hp <= 0

class TowerBase: Character
    def TowerBase(_level: LevelScene?; _hp: int)
        // Parmeters
        level = _level
        hp = _hp

        // Animation
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
        takeDamageAnimation = seq

    def override animateTakeDamage(): void
        if takeDamageAnimation.isDisabled
            takeDamageAnimation->reset()
            addAction(takeDamageAnimation)

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