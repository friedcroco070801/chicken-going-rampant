require daslib/media
module node public

class Node
    x, y: float = 0.0f
    anchorX, anchorY: float = 0.0f
    isAnimated: bool = false
    tint: uint = 0xFFFFFFFF
    actionLists: array<Action?>
    scaleX, scaleY: float = 1.0f

    def abstract draw(): void

    def update(dt: float): void
        isAnimated = false
        for action in actionLists
            action->perform(self, dt)

    def setPosition(_x, _y: float): void
        x = _x
        y = _y
    
    def setAnchor(_anchorX, _anchorY: float): void
        anchorX = _anchorX
        anchorY = _anchorY

    def addAction(action: Action?): void
        actionLists |> push(action)

class Rect : Node
    width, height: int = 0

    def override draw(): void
        pass

    def override update(dt: float): void
        pass

class Action
    isDisabled: bool = false

    def abstract perform(var node: Node; dt: float): void

    def abstract draw(node: Node): void

    def abstract reset(): void

class RepeatForever: Action
    action: Action?

    def RepeatForever(_action: Action?)
        action = _action

    def override perform(var node: Node; dt: float): void
        if action.isDisabled
            action->reset()
        action->perform(node, dt)

    def override draw(node: Node): void
        action->draw(node)

    def override reset(): void
        isDisabled = false
