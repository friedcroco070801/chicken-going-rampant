require daslib/media
module node public

class Node
    x, y: float = 0.0f
    width, height: float = 0.0f
    anchorX, anchorY: float = 0.0f
    isAnimated: bool = false
    tint: uint = 0xFFFFFFFF
    actionLists: array<Action?>
    scaleX, scaleY: float = 1.0f
    isRemoved: bool = false

    def finalize
        for action in actionLists
            unsafe
                delete action

    def draw(): void
        for action in actionLists
            action->draw(self)

    def update(dt: float): void
        isAnimated = false

        // Remove disabled actions
        var i: int = 0
        while i < actionLists |> length()
            if actionLists[i] == null
                actionLists |> erase(i)
                i--
            elif actionLists[i].isDisabled
                if actionLists[i].deletedOnDisabled
                    unsafe
                        delete actionLists[i]
                actionLists |> erase(i)
                i--
            i++

        // Perform actions
        i = 0
        while i < actionLists |> length()
            actionLists[i]->perform(self, dt)
            i++

        // Remove disabled actions
        i = 0
        while i < actionLists |> length()
            if actionLists[i].isDisabled
                actionLists |> erase(i)
                i--
            i++

    def setPosition(_x, _y: float): void
        x = _x
        y = _y
    
    def setAnchor(_anchorX, _anchorY: float): void
        anchorX = _anchorX
        anchorY = _anchorY

    def setScale(_scaleX, _scaleY: float): void
        scaleX = _scaleX
        scaleY = _scaleY
    
    def setColor(_tint: uint): void
        let t = uint(256 * 256 * 256)
        tint = (tint / t) * t + _tint % t

    def setOpacity(opacity: float): void
        let t = uint(256 * 256 * 256)
        tint = tint % t + uint(opacity * 256.0f) * t

    def addAction(action: Action?): void
        actionLists |> push(action)

    def removeFromScene(): void
        isRemoved = true

    def removeAllAnimations(): void
        var i: int = 0
        while i < actionLists |> length()
            if actionLists[i]->isAnimation()
                if actionLists[i].deletedOnDisabled
                    unsafe
                        delete actionLists[i]
                actionLists |> erase(i)
                i--
            i++
        isAnimated = false

    def pauseAllActions(): void
        var i: int = 0
        while i < actionLists |> length()
            actionLists[i].isPaused = true
            i++

    def resumeAllActions(): void
        var i: int = 0
        while i < actionLists |> length()
            actionLists[i].isPaused = false
            i++

    def abstract funcCallStored1(): void
    def abstract funcCallStored2(): void
    def abstract funcCallStored3(): void
    def abstract funcCallStored4(): void

class Action
    isDisabled: bool = false
    isPaused: bool = false
    interval: float = 0.0f
    deletedOnDisabled: bool = true

    def abstract perform(var node: Node; dt: float): void

    def abstract draw(node: Node): void

    def abstract reset(): void

    def setDisable(): void
        isDisabled = true

    def keepOnDisabled(): void
        deletedOnDisabled = false

    def isAnimation(): bool
        return false

class RepeatForever: Action
    action: Action?

    def finalize
        unsafe
            delete action

    def RepeatForever(_action: Action?)
        action = _action

    def override perform(var node: Node; dt: float): void
        if !isDisabled && !isPaused
            if action.isDisabled
                action->reset()
            action->perform(node, dt)

    def override draw(node: Node): void
        action->draw(node)

    def override reset(): void
        isDisabled = false

class MoveBy: Action
    timer: float = 0.0f
    delta: float2 = float2(0.0f, 0.0f)
    d: float2 = float2(0.0f, 0.0f)

    def MoveBy(_delta: float2; _interval: float)
        delta = _delta
        interval = _interval

    def override perform(var node: Node; dt: float): void
        if !isDisabled && !isPaused
            timer = timer + dt
            if timer >= interval
                isDisabled = true
                node.x = node.x - d.x + delta.x
                node.y = node.y - d.y + delta.y
            else
                node.x = node.x - d.x
                node.y = node.y - d.y
                d = timer / interval * delta
                node.x = node.x + d.x
                node.y = node.y + d.y

    def override draw(node: Node): void
        pass

    def override reset(): void
        d = float2(0.0f, 0.0f)
        timer = 0.0f
        isDisabled = false

class MoveAnchorBy: Action
    timer: float = 0.0f
    delta: float2 = float2(0.0f, 0.0f)
    d: float2 = float2(0.0f, 0.0f)

    def MoveAnchorBy(_delta: float2; _interval: float)
        delta = _delta
        interval = _interval

    def override perform(var node: Node; dt: float): void
        if !isDisabled && !isPaused
            timer = timer + dt
            if timer >= interval
                isDisabled = true
                node.anchorX = node.anchorX - d.x + delta.x
                node.anchorY = node.anchorY - d.y + delta.y
            else
                node.anchorX = node.anchorX - d.x
                node.anchorY = node.anchorY - d.y
                d = timer / interval * delta
                node.anchorX = node.anchorX + d.x
                node.anchorY = node.anchorY + d.y

    def override draw(node: Node): void
        pass

    def override reset(): void
        d = float2(0.0f, 0.0f)
        timer = 0.0f
        isDisabled = false

class JumpBy: Action
    timer: float = 0.0f
    delta: float2 = float2(0.0f, 0.0f)
    d: float2 = float2(0.0f, 0.0f)
    height: float = 0.0f
    h: float = 0.0f

    def JumpBy(_delta: float2; _height: float; _interval: float)
        delta = _delta
        height = _height
        interval = _interval

    def override perform(var node: Node; dt: float): void
        if !isDisabled && !isPaused
            timer = timer + dt
            if timer >= interval
                isDisabled = true
                node.x = node.x - d.x + delta.x
                node.y = node.y - d.y - h + delta.y
            else
                node.x = node.x - d.x
                node.y = node.y - d.y
                node.y = node.y - h
                d = timer / interval * delta
                h = 4.0f * height / interval * timer - 4.0f * height / (interval * interval) * timer * timer 
                node.x = node.x + d.x
                node.y = node.y + d.y
                node.y = node.y + h

    def override draw(node: Node): void
        pass

    def override reset(): void
        d = float2(0.0f, 0.0f)
        h = 0.0f
        timer = 0.0f
        isDisabled = false

class TintTo: Action
    timer: float = 0.0f
    tint: uint  = 0xffffff
    dtint: int = 0
    stint: int = 0
    _once: bool = false

    def TintTo(_tint: uint; _interval: float)
        tint = _tint
        interval = _interval

    def override perform(var node: Node; dt: float): void
        if !_once
            _once = true
            stint = int(node.tint % 0x01000000)
        if !isDisabled && !isPaused
            timer = timer + dt
            if timer >= interval
                isDisabled = true
                node->setColor(tint)
            else
                dtint = int(float(int(tint) - stint) * timer / interval)
                node->setColor(uint(stint + dtint))
                
    def override draw(node: Node): void
        pass

    def override reset(): void
        dtint = 0
        stint = 0
        _once = false
        timer = 0.0f
        isDisabled = false

class FadeIn: Action
    timer: float = 0.0f
    opacity: float = 0.0f

    def FadeIn(_interval: float)
        interval = _interval

    def override perform(var node: Node; dt: float): void
        if !isDisabled && !isPaused
            timer = timer + dt
            if timer >= interval
                isDisabled = true
                node->setOpacity(1.0f)
            else
                opacity = timer / interval
                node->setOpacity(opacity)

    def override draw(node: Node): void
        pass

    def override reset(): void
        timer = 0.0f
        isDisabled = false

class FadeOut: Action
    timer: float = 0.0f
    opacity: float = 1.0f

    def FadeOut(_interval: float)
        interval = _interval

    def override perform(var node: Node; dt: float): void
        if !isDisabled && !isPaused
            timer = timer + dt
            if timer >= interval
                isDisabled = true
                node->setOpacity(0.0f)
            else
                opacity = 1.0f - timer / interval
                node->setOpacity(opacity)

    def override draw(node: Node): void
        pass

    def override reset(): void
        timer = 0.0f
        isDisabled = false

class ScaleBy: Action
    timer: float = 0.0f
    scale: float2 = float2(1.0f, 1.0f)
    dscale: float2 = float2(1.0f, 1.0f)

    def ScaleBy(_scale: float2; _interval: float)
        scale = _scale
        interval = _interval

    def override perform(var node: Node; dt: float): void
        if !isDisabled && !isPaused
            timer = timer + dt
            if timer >= interval
                isDisabled = true
                node.scaleX = node.scaleX / dscale.x * scale.x
                node.scaleY = node.scaleY / dscale.y * scale.y
            else
                node.scaleX = node.scaleX / dscale.x
                node.scaleY = node.scaleY / dscale.y
                dscale = timer / interval * (scale - float2(1.0f, 1.0f)) + float2(1.0f, 1.0f)
                node.scaleX = node.scaleX * dscale.x
                node.scaleY = node.scaleY * dscale.y
                
    def override draw(node: Node): void
        pass

    def override reset(): void
        dscale = float2(1.0f, 1.0f)
        timer = 0.0f
        isDisabled = false

class Disappear: Action
    def override perform(var node: Node; dt: float): void
        if !isDisabled && !isPaused
            isDisabled = true
            node->removeFromScene()
                
    def override draw(node: Node): void
        pass

    def override reset(): void
        isDisabled = false

class FuncCall: Action
    func: lambda<(): void>

    def finalize
        unsafe
            delete func

    def setFunc(var _func: lambda<(): void>)
        func <- _func

    def override perform(var node: Node; dt: float): void
        if !isDisabled && !isPaused
            isDisabled = true
            invoke(func)
                
    def override draw(node: Node): void
        pass

    def override reset(): void
        isDisabled = false

class FuncCallStored: Action
    choice: int = 0

    def FuncCallStored(_choice: int)
        choice = _choice

    def override perform(var node: Node; dt: float): void
        if !isDisabled && !isPaused
            isDisabled = true
            if choice == 1
                node->funcCallStored1()
            elif choice == 2
                node->funcCallStored2()
            elif choice == 3
                node->funcCallStored3()
            elif choice == 4
                node->funcCallStored4()
                
    def override draw(node: Node): void
        pass

    def override reset(): void
        isDisabled = false

class Wait: Action
    timer: float = 0.0f

    def Wait(_interval: float)
        interval = _interval

    def override perform(var node: Node; dt: float): void
        if !isDisabled && !isPaused
            timer = timer + dt
            if timer >= interval
                isDisabled = true
            else
                pass
                
    def override draw(node: Node): void
        pass

    def override reset(): void
        timer = 0.0f
        isDisabled = false

class Sequence: Action
    index: int = 0
    actions: array<Action?>

    def finalize
        for action in actions
            unsafe
                delete action

    def addAction(action: Action?): void
        actions |> push(action)
        if action.interval > 0.0f
            interval = 1.0f

    def override perform(var node: Node; dt: float): void
        if !isDisabled && !isPaused
            if index >= actions |> length()
                isDisabled = true
            else
                while index < actions |> length()
                    if actions[index].interval == 0.0f
                        actions[index]->perform(node, dt)
                        if actions[index].isDisabled
                            index = index + 1
                        else
                            break
                    else
                        actions[index]->perform(node, dt)
                        break
                if index >= actions |> length()
                    isDisabled = true
                    return
                if actions[index].isDisabled
                    index = index + 1
                    if index >= actions |> length()
                        isDisabled = true
                
    def override draw(node: Node): void
        if !isDisabled
            if index >= actions |> length()
                isDisabled = true
            else
                actions[index]->draw(node)

    def override reset(): void
        index = 0
        for action in actions
            action->reset()
        isDisabled = false

class Parallel: Action
    actions: array<Action?>

    def finalize
        for action in actions
            unsafe
                delete action

    def addAction(action: Action?): void
        actions |> push(action)
        if action.interval > 0.0f
            interval = 1.0f

    def override perform(var node: Node; dt: float): void
        if !isDisabled && !isPaused
            isDisabled = true
            for action in actions
                action->perform(node, dt)
                if !action.isDisabled
                    isDisabled = false
                
    def override draw(node: Node): void
        if !isDisabled
            for action in actions
                action->draw(node)

    def override reset(): void
        for action in actions
            action->reset()
        isDisabled = false