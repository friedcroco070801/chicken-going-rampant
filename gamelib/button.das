require daslib/media
require pentwin/sprite
require pentwin/node

module button public

class Button: Sprite
    clickFunc: lambda<(): void>
    filename: string
    filenameclicked: string
    isClicked: bool = false

    def finalize
        unsafe
            delete clickFunc

    def Button(_filename: string; _filenameclicked: string)
        Sprite`Sprite(self, _filename)
        filename = _filename
        filenameclicked = _filenameclicked

    def setFunc(var func: lambda<(): void>): void
        clickFunc <- func

    def onClick(): void
        if !isClicked
            isClicked = true
            var anim: Animation? = new Animation()
            anim->addFrame(new AnimFrame(filenameclicked, 0.1f))
            anim->addFrame(new AnimFrame(filename, 0.1f))
            var seq: Sequence? = new Sequence()
            seq->addAction(anim)
            var afterClick: FuncCall? = new FuncCall()
            unsafe
                afterClick->setFunc() <| @ [[&self]]
                    if self.clickFunc != null
                        invoke(self.clickFunc)
                    isClicked = false
                seq->addAction(afterClick)
            addAction(seq)