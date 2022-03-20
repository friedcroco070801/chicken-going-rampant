module constant public

let shared public
    CENTISEC = 0.01f
    LINE_START = 240.0f
    LINE_END = 1120.0f
    LINE_GROUND = 540.0f
    MAX_WORKER = 5
    MAX_BAR = 6

    JUMP_DIE_HEIGHT = -200.0f
    JUMP_DIE_DELTA_X = 100.0f
    JUMP_DIE_DELTA_Y = 360.0f
    JUMP_DIE_INTERVAL = 1.0f

var public
    COST_TABLE <- {{1 => 100; 2 => 200; 3 => 300; 4 => 400; 5 => 9999}}

enum public CharacterCode
    NONE = -1
    A00_BASE = 000
    A01_NORMAL = 001
    A02_FIRE = 002
    A03_ICE = 003
    A04_TREE = 004
    A05_BOMB = 005
    A06_FIRETREE = 006
    A07_ICETREE = 007
    B01_FIRE = 101
    B02_ICE = 102
    B03_TREE = 103
    E00_BASE = 200
    E01_NORMAL = 201
    E02_CAT = 202
    E03_BIRD = 203
    E04_CROCO = 204
    E05_ELEPHANT = 205

enum public AttackType
    NONE
    SINGLE
    AREA

enum public CharacterState
    IDLING
    MOVING
    ATTACKING

let shared public
    BACKDROP = "gamelib/assets/sprites/background/backdrop.png"
    GROUND = "gamelib/assets/sprites/background/ground.png"
    CLOUD = "gamelib/assets/sprites/background/cloud.png"
    MOUNTAIN = "gamelib/assets/sprites/background/mountain.png"
    TREE = "gamelib/assets/sprites/background/tree.png"
    ARMY_BASE = "gamelib/assets/sprites/tower/base.png"
    ENEMY_BASE = "gamelib/assets/sprites/tower/enemy.png"
    WORKER = "gamelib/assets/sprites/character/worker.png"
    ARMY01 = "gamelib/assets/sprites/character/a01.png"
    ARMY02 = "gamelib/assets/sprites/character/a02.png"
    ARMY03 = "gamelib/assets/sprites/character/a03.png"
    ARMY04 = "gamelib/assets/sprites/character/a04.png"
    ARMY05 = "gamelib/assets/sprites/character/a05.png"
    ARMY06 = "gamelib/assets/sprites/character/a06.png"
    ARMY07 = "gamelib/assets/sprites/character/a07.png"
    ENEMY01 = "gamelib/assets/sprites/character/e01.png"
    ENEMY02 = "gamelib/assets/sprites/character/e02.png"
    ENEMY03 = "gamelib/assets/sprites/character/e03.png"
    ENEMY04 = "gamelib/assets/sprites/character/e04.png"
    ENEMY05 = "gamelib/assets/sprites/character/e05.png"
    EGG01 = "gamelib/assets/sprites/character/b01.png"
    EGG02 = "gamelib/assets/sprites/character/b02.png"
    EGG03 = "gamelib/assets/sprites/character/b03.png"
    FIRE_EFFECT = "gamelib/assets/sprites/effect/fire.png"
    ICE_EFFECT = "gamelib/assets/sprites/effect/ice.png"
    LEAF_EFFECT = "gamelib/assets/sprites/effect/leaf.png"
    EXPLODE_EFFECT = "gamelib/assets/sprites/effect/explode.png"
    NUMBER_FONT = "gamelib/assets/sprites/utils/number.png"
    BAR_BASE = "gamelib/assets/sprites/bar/base.png"
    BAR_BOMB = "gamelib/assets/sprites/bar/bomb.png"
    BAR_NORMAL = "gamelib/assets/sprites/bar/normal.png"
    BAR_FIRE = "gamelib/assets/sprites/bar/fire.png"
    BAR_ICE = "gamelib/assets/sprites/bar/ice.png"
    BAR_LEAF = "gamelib/assets/sprites/bar/seed.png"
    BAR_WORKER = "gamelib/assets/sprites/bar/worker.png"
    BAR_RECHARGE = "gamelib/assets/sprites/bar/recharge.png"
    BAR_FLASH = "gamelib/assets/sprites/bar/flash.png"
    BAR_LOCK = "gamelib/assets/sprites/bar/lock.png"
    ENERGY_BAR = "gamelib/assets/sprites/bar/counter.png"
    RESULT_FLASH = "gamelib/assets/sprites/result/flash_bg.jpg"
    RESULT_FORE = "gamelib/assets/sprites/result/fore_bg.jpg"
    RESULT_LOSE = "gamelib/assets/sprites/result/lose_noti.png"
    RESULT_VICTORY = "gamelib/assets/sprites/result/victory_noti.png"
    EFFECT_STAR = "gamelib/assets/sprites/result/star.png"