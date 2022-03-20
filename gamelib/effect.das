require pentwin/node
require pentwin/sprite
require pentwin/utils
require math
require constant

module effect public

class Eruption: Action
    sprites: array<Sprite?>
    timer: float = 0.0f
    
    def finalize
        for sprite in sprites
            unsafe
                delete sprite

    def Eruption(_interval: float; _height: float; _center: float2; _innerrad: float; _radius: float; _spots: int)
        interval = _interval
        for i in range(0, _spots)
            var sp: Sprite? = new Sprite(FIRE_EFFECT, float4(0.0f, 0.0f, 32.0f, 32.0f))
            sp->setAnchor(0.5f, 0.5f)
            sp->setPosition(_center.x + _innerrad * (2.0f * randFloat01() - 1.0f), _center.y)
            var scale: float = 1.0f + randFloat01() * 0.75f
            sp->setScale(scale, scale)
            var dur: float = _interval * 0.4f + _interval * 0.6f * randFloat01()
            var seq: Sequence? = new Sequence()
            var anim: Animation? = new Animation()
            for j in range(0, 6)
                var frame: AnimFrame? = new AnimFrame(FIRE_EFFECT, dur / 6.0f, float4(32.0f * float(j), 0.0f, 32.0f, 32.0f))
                anim->addFrame(frame)
            seq->addAction(anim)
            seq->addAction(new Disappear())
            sp->addAction(seq)
            sp->addAction(new JumpBy(float2(_radius, 0.0f) * (randFloat01() * 2.0f - 1.0f), _height * 0.5f * (1.0f + randFloat01()), dur))
            sprites |> push(sp)

    def override perform(var node: Node; dt: float): void
        if !isDisabled && !isPaused
            timer = timer + dt
            if timer > interval
                isDisabled = true
            for sprite in sprites
                if !sprite.isRemoved
                    sprite->update(dt)
                
    def override draw(node: Node): void
        if !isDisabled
            for sprite in sprites
                if !sprite.isRemoved
                    sprite->draw()

    def override reset(): void
        // Cannot be reset completely
        for sprite in sprites
            sprite.isRemoved = false
        isDisabled = false

class Blizzard: Action
    sprites: array<Sprite?>
    timer: float = 0.0f

    def finalize
        for sprite in sprites
            unsafe
                delete sprite

    def Blizzard(_interval: float; _height: float; _center: float2; _innerrad: float; _radius: float; _spots: int)
        interval = _interval
        for i in range(0, _spots)
            var sp: Sprite? = new Sprite(ICE_EFFECT, float4(0.0f, 0.0f, 32.0f, 32.0f))
            sp->setAnchor(0.5f, 0.5f)
            sp->setPosition(_center.x + _innerrad * (2.0f * randFloat01() - 1.0f), _center.y)
            var scale: float = 1.0f + randFloat01() * 0.75f
            sp->setScale(scale, scale)
            var dur: float = _interval * 0.4f + _interval * 0.6f * randFloat01()
            var seq: Sequence? = new Sequence()
            var anim: Animation? = new Animation()
            for j in range(0, 6)
                var frame: AnimFrame? = new AnimFrame(ICE_EFFECT, dur / 6.0f, float4(32.0f * float(j), 0.0f, 32.0f, 32.0f))
                anim->addFrame(frame)
            seq->addAction(anim)
            seq->addAction(new Disappear())
            sp->addAction(seq)
            sp->addAction(new JumpBy(float2(_radius, 0.0f) * (randFloat01() * 2.0f - 1.0f), _height * 0.5f * (1.0f + randFloat01()), dur))
            sprites |> push(sp)

    def override perform(var node: Node; dt: float): void
        if !isDisabled && !isPaused
            timer = timer + dt
            if timer > interval
                isDisabled = true
            for sprite in sprites
                if !sprite.isRemoved
                    sprite->update(dt)
                
    def override draw(node: Node): void
        if !isDisabled
            for sprite in sprites
                if !sprite.isRemoved
                    sprite->draw()

    def override reset(): void
        // Cannot be reset completely
        for sprite in sprites
            sprite.isRemoved = false
        isDisabled = false

class LeafStorm: Action
    sprites: array<Sprite?>
    timer: float = 0.0f

    def finalize
        for sprite in sprites
            unsafe
                delete sprite

    def LeafStorm(_interval: float; _height: float; _center: float2; _innerrad: float; _radius: float; _spots: int)
        interval = _interval
        for i in range(0, _spots)
            var sp: Sprite? = new Sprite(LEAF_EFFECT, float4(160.0f, 0.0f, 32.0f, 32.0f))
            sp->setAnchor(0.5f, 0.5f)
            sp->setPosition(_center.x + _innerrad * (2.0f * randFloat01() - 1.0f), _center.y)
            var scale: float = 0.75f + randFloat01() * 0.5f
            sp->setScale(scale * float(randIntM11()), scale * float(randIntM11()))
            var dur: float = _interval * 0.4f + _interval * 0.6f * randFloat01()
            var seq: Sequence? = new Sequence()
            var anim: Animation? = new Animation()
            for j in range(0, 6)
                var frame: AnimFrame? = new AnimFrame(LEAF_EFFECT, dur / 6.0f, float4(32.0f * float(j), 0.0f, 32.0f, 32.0f))
                anim->addFrame(frame)
            seq->addAction(anim)
            seq->addAction(new Disappear())
            sp->addAction(seq)
            sp->addAction(new JumpBy(float2(_radius, 0.0f) * (randFloat01() * 2.0f - 1.0f), _height * 0.5f * (1.0f + randFloat01()), dur))
            sprites |> push(sp)

    def override perform(var node: Node; dt: float): void
        if !isDisabled && !isPaused
            timer = timer + dt
            if timer > interval
                isDisabled = true
            for sprite in sprites
                if !sprite.isRemoved
                    sprite->update(dt)
                
    def override draw(node: Node): void
        if !isDisabled
            for sprite in sprites
                if !sprite.isRemoved
                    sprite->draw()

    def override reset(): void
        // Cannot be reset completely
        for sprite in sprites
            sprite.isRemoved = false
        isDisabled = false

class Explosion: Action
    sprites: array<Sprite?>
    timer: float = 0.0f

    def finalize
        for sprite in sprites
            unsafe
                delete sprite
                
    def Explosion(_interval: float; _center: float2; _radius: float; _spots: int)
        interval = _interval
        for i in range(0, _spots)
            var sp: Sprite? = new Sprite(EXPLODE_EFFECT, float4(576.0f, 0.0f, 64.0f, 64.0f))
            sp->setAnchor(0.5f, 0.5f)
            sp->setPosition(_center.x + _radius * (1.8f * randFloat01() - 0.9f), _center.y + _radius * (1.8f * randFloat01() - 0.9f))
            var scale: float = 0.6f + randFloat01() * 0.6f
            sp->setScale(scale, scale)
            var dur: float = min(_interval, 0.3f)
            var predur: float = (_interval - dur) * randFloat01()
            var seq: Sequence? = new Sequence()
            var anim: Animation? = new Animation()
            for j in range(0, 9)
                var frame: AnimFrame? = new AnimFrame(EXPLODE_EFFECT, dur / 9.0f, float4(64.0f * float(j), 0.0f, 64.0f, 64.0f))
                anim->addFrame(frame)
            seq->addAction(new Wait(predur))
            seq->addAction(anim)
            seq->addAction(new Disappear())
            sp->addAction(seq)
            sprites |> push(sp)

    def override perform(var node: Node; dt: float): void
        if !isDisabled && !isPaused
            timer = timer + dt
            if timer > interval
                isDisabled = true
            for sprite in sprites
                if !sprite.isRemoved
                    sprite->update(dt)
                
    def override draw(node: Node): void
        if !isDisabled
            for sprite in sprites
                if !sprite.isRemoved
                    sprite->draw()

    def override reset(): void
        // Cannot be reset completely
        for sprite in sprites
            sprite.isRemoved = false
        isDisabled = false

class StarBurst: Action
    sprites: array<Sprite?>
    timer: float = 0.0f

    def finalize
        for sprite in sprites
            unsafe
                delete sprite

    def StarBurst(_interval: float; _height: float; _center: float2; _radius: float2; _spots: int)
        interval = _interval
        for i in range(0, _spots)
            var sp: Sprite? = new Sprite(EFFECT_STAR)
            sp->setAnchor(0.5f, 0.5f)
            sp->setPosition(_center.x, _center.y)
            var scale: float = 0.75f + randFloat01() * 0.5f
            sp->setScale(scale * float(randIntM11()), scale * float(randIntM11()))
            var seq: Sequence? = new Sequence()
            seq->addAction(new FadeOut(_interval))
            seq->addAction(new Disappear())
            sp->addAction(seq)
            sp->addAction(new JumpBy(float2(_radius.x * (randFloat01() * 2.0f - 1.0f), _radius.y * (randFloat01() * 2.0f - 1.0f)), _height * 0.5f * (1.0f + randFloat01()), _interval))
            sprites |> push(sp)

    def override perform(var node: Node; dt: float): void
        if !isDisabled && !isPaused
            timer = timer + dt
            if timer > interval
                isDisabled = true
            for sprite in sprites
                if !sprite.isRemoved
                    sprite->update(dt)
                
    def override draw(node: Node): void
        if !isDisabled
            for sprite in sprites
                if !sprite.isRemoved
                    sprite->draw()

    def override reset(): void
        // Cannot be reset completely
        for sprite in sprites
            sprite.isRemoved = false
        isDisabled = false