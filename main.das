require daslib/media
require gamelib/level
require gamelib/pentwin/application

[export]
def initialize()
    set_window_title("Chicken Going Rampant")
    set_resolution(1280, 720)

    getApplication() = new Application("menu", new LevelScene())

[export]
def act(dt: float)
    getApplication()->update(dt)

[export]
def draw()
    enable_alpha_blend()
    getApplication()->draw()