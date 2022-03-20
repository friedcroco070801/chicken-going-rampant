require daslib/media
require pentwin/sprite
require pentwin/node
require constant

module counter public

class Counter: Node
    value: int = 0
    digits: array<Sprite?>
    scale: float = 1.0f
    leftAligned: bool = true

    def finalize
        for digit in digits
            unsafe
                delete digit

    def Counter()
        for i in range(0, 10)
            var digit: Sprite? = new Sprite(NUMBER_FONT, float4(64.0f * float(i), 0.0f, 64.0f, 96.0f))
            digit->setAnchor(0.0f, 0.5f)
            digits |> push(digit)

    def setValue(_value: int): void
        value = _value

    def setLeftAligned(_left: bool): void
        leftAligned = _left
        for digit in digits
            if _left
                digit->setAnchor(0.0f, 0.5f)
            else
                digit->setAnchor(1.0f, 0.5f)

    def setFontScale(_scale: float): void
        scale = _scale
        for sprite in digits
            sprite->setScale(_scale, _scale)

    def override draw(): void
        var curX: float = x
        var temp: array<int>
        var n: int = value
        
        while n > 0
            if leftAligned
                temp |> push(n % 10, 0)
            else
                temp |> push(n % 10)
            n = n / 10
        if temp |> length() == 0
            temp |> push(0)

        for num in temp
            digits[num]->setPosition(curX, y)
            digits[num]->setColor(tint)
            digits[num]->draw()
            curX = curX + (leftAligned ? 1.0f : -1.0f) * 64.0f * scale

        delete temp

        Node`draw(self)
