require daslib/media
require gamelib/pentwin/scene
require gamelib/pentwin/application

[export]
def initialize()
    set_window_title("Chicken Going Rampant")
    set_resolution(1280, 720)
    enable_alpha_blend()

    getApplication() = new Application("menu", new Scene())

[export]
def act(dt: float)
    getApplication()->update(dt)

[export]
def draw()
    getApplication()->draw()