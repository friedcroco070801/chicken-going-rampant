require daslib/media
require pentwin/sprite
require pentwin/node

var sprite: Sprite?

[export]
def initialize()
    set_window_title("Chicken Going Rampant")
    set_resolution(1280, 720)

    sprite = new Sprite("assets/charman.png", float4(0.0f, 0.0f, 42.0f, 42.0f))
    sprite->setPosition(100.0f, 100.0f)
    sprite->setScale(2.0f, 2.0f)
    sprite->setAnchor(0.5f, 0.5f)
    
    var animation: Animmation? = new Animmation()
    var i = 0
    while i < 18
        var frame: AnimFrame? = new AnimFrame("assets/charman.png", 1.0f, float4(float(i) * 42.0f, 0.0f, 42.0f, 42.0f))
        animation->addFrame(frame)
        sprite->addAction(new RepeatForever(animation))
        i = i + 1

[export]
def act(dt: float)
    if get_key(VK_ESCAPE)
        schedule_quit_game()

    sprite->update(dt)

[export]
def draw()
    sprite->draw()