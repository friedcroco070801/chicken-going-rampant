require node
require daslib/media

module sprite public

class Sprite: Node
    image: ImageHandle
    width, height: float = 0.0f
    tint: uint = 0xFFFFFFFF
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

    def setSize(_width, _height: float): void
        width = _width
        height = _height
    
    def setColor(_tint: uint): void
        tint = _tint

    def setOpacity(opacity: float): void
        let t = uint(256 * 256 * 256)
        tint = tint % t + uint(opacity * 256.0f) * t

    def override draw(): void
        image |> draw_image_region(x - anchorX * width, y - anchorY * height, rect, tint, float2(width, height))

    def override update(dt: float): void
        var t: int

class Animmation: Action
    anims: array<ImageHandle>

    def override perform(dt: float): void
        var t: int