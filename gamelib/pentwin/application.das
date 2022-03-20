require scene
module application public

var application: Application?

def getApplication(): Application?&
    unsafe
        return application

class Application
    scenes: table<string; Scene?>
    curScene: Scene?

    def finalize
        unsafe
            delete scenes

    def Application(_key: string; _scene: Scene?)
        scenes[_key] = _scene
        curScene = _scene
        curScene->initialize()

    def getCurrentScene(): Scene?
        return curScene

    def addScene(_key: string; var _scene: Scene?): void
        scenes[_key] = _scene
        _scene->initialize()

    def changeScene(_key: string): void
        curScene = scenes[_key]

    def update(dt: float): void
        curScene->update(dt)
    
    def draw(): void
        curScene->draw()