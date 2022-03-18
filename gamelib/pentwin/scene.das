require node
require daslib/media
module scene public

class Event
    isRemoved: bool = false
    isPaused: bool = false

    def abstract update(dt: float): void

    def removeFromScene(): void
        isRemoved = true

class ClickOn: Event
    onMouseDown: lambda<(): void>
    onMousePress: lambda<(): void>
    onMouseUp: lambda<(): void>
    node: Node?

    def ClickOn(_node: Node?)
        node = _node

    def setOnMouseDown(var func: lambda<(): void>): void
        onMouseDown <- func

    def setOnMousePress(var func: lambda<(): void>): void
        onMousePress <- func

    def setOnMouseUp(var func: lambda<(): void>): void
        onMouseUp <- func

    def override update(dt: float): void
        if node.isRemoved
            isRemoved = true
            return
        if isPaused
            return
        var left: float = node.x - node.anchorX * node.width * node.scaleX
        var right: float = node.x + (1.0f - node.anchorX) * node.width * node.scaleX
        var upper: float = node.y - node.anchorY * node.height * node.scaleY
        var lower: float = node.y + (1.0f - node.anchorY) * node.height * node.scaleY
        var pos: float2 = get_mouse_position()
        if pos.x >= left && pos.x <= right && pos.y >= upper && pos.y <= lower
            if get_mouse_button(MB_LEFT) && onMousePress != null
                invoke(onMousePress)
            if get_mouse_button_down(MB_LEFT) && onMouseDown != null
                invoke(onMouseDown)
            if get_mouse_button_up(MB_LEFT) && onMouseUp != null
                invoke(onMouseUp)

class Scene
    children: array<Node?>
    events: array<Event?>

    def initialize(): void 
        pass

    def update(dt: float): void
        // Remove removed children
        var i: int = 0
        while i < children |> length()
            if children[i].isRemoved
                children |> erase(i)
                i--
            i++

        // Remove removed events
        i = 0
        while i < events |> length()
            if events[i].isRemoved
                events |> erase(i)
                i--
            i++

        // Update children
        for child in children
            child->update(dt)

        // Listen to event
        for event in events
            event->update(dt)

    def draw(): void
        for child in children
            child->draw()

    def addChild(node: Node?): void
        children |> push(node)

    def addEvent(event: Event?): void
        events |> push(event)

    def removeAllEvents(): void
        var i: int = 0
        while i < events |> length()
            events[i].isRemoved = true
            i++

    def pauseAllEvents(): void
        var i: int = 0
        while i < events |> length()
            events[i].isPaused = true
            i++

    def resumeAllEvents(): void
        var i: int = 0
        while i < events |> length()
            events[i].isPaused = false
            i++

    def pauseAllActions(): void
        var i: int = 0
        while i < children |> length()
            children[i]->pauseAllActions()
            i++

    def resumeAllActions(): void
        var i: int = 0
        while i < children |> length()
            children[i]->resumeAllActions()
            i++