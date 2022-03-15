require daslib/media
module node public

class Node
    x, y: float = 0.0f
    anchorX, anchorY: float = 0.0f
    isAnimated: bool = false
    actionLists: array<Action?>

    def abstract draw(): void

    def abstract update(dt: float): void

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
        var t: int

    def override update(dt: float): void
        var t: int

class Action
    node: Node?

    def abstract perform(dt: float): void
