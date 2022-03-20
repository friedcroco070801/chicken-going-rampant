require daslib/media
require gamelib/level
require gamelib/pentwin/application
require gamelib/pentwin/spritepool
require gamelib/constant

def preload()
    preloadImage(BACKDROP)
    preloadImage(GROUND)
    preloadImage(CLOUD)
    preloadImage(MOUNTAIN)
    preloadImage(TREE)
    preloadImage(ARMY_BASE)
    preloadImage(ENEMY_BASE)
    preloadImage(WORKER)
    preloadImage(ARMY01)
    preloadImage(ARMY02)
    preloadImage(ARMY03)
    preloadImage(ARMY04)
    preloadImage(ARMY05)
    preloadImage(ARMY06)
    preloadImage(ARMY07)
    preloadImage(ENEMY01)
    preloadImage(ENEMY02)
    preloadImage(ENEMY03)
    preloadImage(ENEMY04)
    preloadImage(ENEMY05)
    preloadImage(EGG01)
    preloadImage(EGG02)
    preloadImage(EGG03)
    preloadImage(FIRE_EFFECT)
    preloadImage(ICE_EFFECT)
    preloadImage(LEAF_EFFECT)
    preloadImage(EXPLODE_EFFECT)
    preloadImage(NUMBER_FONT)
    preloadImage(BAR_BASE)
    preloadImage(BAR_BOMB)
    preloadImage(BAR_NORMAL)
    preloadImage(BAR_FIRE)
    preloadImage(BAR_ICE)
    preloadImage(BAR_LEAF)
    preloadImage(BAR_WORKER)
    preloadImage(BAR_RECHARGE)
    preloadImage(BAR_FLASH)
    preloadImage(BAR_LOCK)
    preloadImage(ENERGY_BAR)
    preloadImage(RESULT_FLASH)
    preloadImage(RESULT_FORE)
    preloadImage(RESULT_LOSE)
    preloadImage(RESULT_VICTORY)
    preloadImage(EFFECT_STAR)

[export]
def initialize()
    set_window_title("Chicken Going Rampant")
    set_resolution(1280, 720)

    preload()

    getApplication() = new Application("menu", new LevelScene())

[export]
def act(dt: float)
    getApplication()->update(dt)

[export]
def draw()
    enable_alpha_blend()
    getApplication()->draw()

    text_out(80, 20, "debug({erhh})", 0xff000000)