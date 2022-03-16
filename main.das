require daslib/media
require pentwin/sprite
require pentwin/node
require pentwin/scene
require pentwin/application

[export]
def initialize()
    set_window_title("Chicken Going Rampant")
    set_resolution(1280, 720)

    var scene = new Scene()
    getApplication() = new Application("menu", scene)

    var sprite = new Sprite("assets/charman.png", float4(0.0f, 0.0f, 42.0f, 42.0f))
    sprite->setPosition(100.0f, 200.0f)
    sprite->setScale(2.0f, -2.0f)
    sprite->setAnchor(0.5f, 0.5f)
    
    var animation: Animmation? = new Animmation()
    var i = 0
    while i < 18
        var frame: AnimFrame? = new AnimFrame("assets/charman.png", 0.05f, float4(float(i) * 42.0f, 0.0f, 42.0f, 42.0f))
        animation->addFrame(frame)
        i = i + 1

    sprite->addAction(new RepeatForever(animation))
    scene->addChild(sprite)

    unsafe
        var click: ClickOn? = new ClickOn(sprite)
        click->setOnMouseUp() <| @ [[=sprite]]
            var otherScene: Scene? = new Scene()
            getApplication()->addScene("new", otherScene)
            getApplication()->changeScene("new")
        scene->addEvent(click)

[export]
def act(dt: float)
    getApplication()->update(dt)

[export]
def draw()
    getApplication()->draw()