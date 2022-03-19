require node
require daslib/media

module sprite public

class Sprite: Node
    image: ImageHandle
    rect: float4 = float4(0.0f, 0.0f, 0.0f, 0.0f)

    def Sprite(filename: string): void
        image <- create_managed_image(filename)
        width = float(image.width)
        height = float(image.height)
        rect = float4(0.0f, 0.0f, width, height)

    def Sprite(filename: string; _rect: float4): void
        image <- create_managed_image(filename)
        width = float(_rect.z)
        height = float(_rect.w)
        rect = _rect

    def override draw(): void
        if !isAnimated
            image |> draw_image_region(x - anchorX * width * scaleX, y - anchorY * height * scaleY, rect, tint, float2(width * scaleX, height * scaleY))

        for action in actionLists
            action->draw(self)

class AnimFrame
    image: ImageHandle
    width, height: float = 0.0f
    rect: float4 = float4(0.0f, 0.0f, 0.0f, 0.0f)
    interval: float = 0.0f

    def AnimFrame(filename: string; _interval: float): void
        image <- create_managed_image(filename)
        width = float(image.width)
        height = float(image.height)
        rect = float4(0.0f, 0.0f, width, height)
        interval = _interval

    def AnimFrame(filename: string; _interval: float; _rect: float4): void
        image <- create_managed_image(filename)
        width = float(_rect.z)
        height = float(_rect.w)
        rect = _rect
        interval = _interval

    def draw(node: Node): void
        image |> draw_image_region(node.x - node.anchorX * width * node.scaleX, node.y - node.anchorY * height * node.scaleY, rect, node.tint, float2(width * node.scaleX, height * node.scaleY))

class Animation: Action
    anims: array<AnimFrame?>
    index: int = 0
    timer: float = 0.0f

    def finalize
        for anim in anims
            unsafe
                delete anim

    def override isAnimation(): bool
        return true

    def override perform(var node: Node; dt: float): void
        if !isDisabled && !isPaused
            if index >= anims |> length()
                isDisabled = true
            else
                node.isAnimated = true
                timer = timer + dt
                while timer >= anims[index].interval
                    timer = timer - anims[index].interval
                    index = index + 1
                    if index >= anims |> length()
                        isDisabled = true
                        node.isAnimated = false
                        break

    def override draw(node: Node): void
        if !isDisabled
            if index >= anims |> length()
                isDisabled = true
            else
                anims[index]->draw(node)

    def override reset(): void
        index = 0
        timer = 0.0f
        isDisabled = false

    def addFrame(frame: AnimFrame?): void
        anims |> push(frame)
        interval = 1.0f