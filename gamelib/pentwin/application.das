require scene
require node
require sprite
module application public

var application: Application?

def getApplication(): Application?&
    unsafe
        return application

class Application
    scenes: table<string; Scene?>
    curScene: Scene?
    isTransitioning: bool = false
    fading: Rectangle?

    def finalize
        unsafe
            delete scenes
        unsafe
            delete fading

    def Application(_key: string; _scene: Scene?)
        scenes[_key] = _scene
        curScene = _scene
        curScene->initialize()
        fading = new Rectangle(1280.0f, 720.0f, 0x00000000)

    def getCurrentScene(): Scene?
        return curScene

    def addScene(_key: string; var _scene: Scene?): void
        scenes[_key] = _scene

    def changeScene(_key: string): void
        curScene->removeAllChildren()
        curScene->removeAllEvents()
        curScene = scenes[_key]
        curScene->initialize()

    def changeSceneWithFading(_key: string; _interval: float): void
        isTransitioning = true
        var seq: Sequence? = new Sequence()
        seq->addAction(new FadeIn(_interval / 2.0f))
        
        var call: FuncCall? = new FuncCall()
        unsafe
            call->setFunc() <| @ [[&self]]
                self.curScene->removeAllChildren()
                self.curScene->removeAllEvents()
                self.curScene = self.scenes[_key]
                self.curScene->initialize()
            seq->addAction(call)
        seq->addAction(new FadeOut(_interval / 2.0f))
        var call2: FuncCall? = new FuncCall()
        unsafe
            call2->setFunc() <| @ [[&self]]
                self.isTransitioning = false
            seq->addAction(call2)
        fading->addAction(seq)

    def update(dt: float): void
        if !isTransitioning
            curScene->update(dt)
        fading->update(dt)
    
    def draw(): void
        curScene->draw()
        fading->draw()