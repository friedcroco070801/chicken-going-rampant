require daslib/media

[export]
def initialize()
    set_window_title("Chicken Going Rampant")
    set_resolution(1280, 720)

[export]
def act(dt: float)
    if get_key(VK_ESCAPE)
        schedule_quit_game()

[export]
def draw()
    if is_window_active()
        print("drawing")