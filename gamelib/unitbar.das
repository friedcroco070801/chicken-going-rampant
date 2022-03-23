require daslib/media
require pentwin/sprite
require pentwin/node
require constant
require counter
require pentwin/soundpool

module unitbar public

class UnitBar: Sprite
    rechargeTime: float = 0.0f
    timer: float = 0.0f
    isDisabled: bool = false
    isRecharging: bool = true
    flash: Sprite?
    fore: Sprite?
    recharge: Sprite?
    cost: Counter?
    costValue: int

    def finalize
        unsafe
            delete flash
        unsafe
            delete recharge
        unsafe
            delete fore
        unsafe
            delete cost

    def UnitBar(_filename: string; _rechargeTime: float; _cost: int)
        Sprite`Sprite(self, _filename)
        rechargeTime = _rechargeTime
        timer = rechargeTime
        setAnchor(0.0f, 1.0f)

        flash = new Sprite(BAR_FLASH)
        flash->setOpacity(0.0f)
        flash->setAnchor(0.0f, 1.0f)

        fore = new Sprite(BAR_RECHARGE)
        fore->setOpacity(0.5f)
        fore->setAnchor(0.0f, 1.0f)

        recharge = new Sprite(BAR_RECHARGE)
        recharge->setOpacity(0.5f)
        recharge->setAnchor(0.0f, 1.0f)

        cost = new Counter()
        cost->setValue(_cost)
        cost->setFontScale(0.25f)
        costValue = _cost

    def override setPosition(_x: float; _y: float)
        Node`setPosition(self, _x, _y)
        flash->setPosition(x, y)
        fore->setPosition(x, y)
        recharge->setPosition(x, y)
        cost->setPosition(x + 12.0f, y - 24.0f)

    def setCost(_cost: int)
        cost->setValue(_cost)
        costValue = _cost

    def override update(dt: float): void
        Node`update(self, dt)
        cost->update(dt)
        fore->update(dt)
        recharge->update(dt)
        flash->update(dt)

    def updateLogicPerCs(): void
        // Update more
        if isDisabled
            fore->setOpacity(0.5f)
            recharge->setScale(1.0f, 1.0f)
        else
            timer = max(0.0f, timer - CENTISEC)
            recharge->setScale(1.0f, timer / rechargeTime)
            if timer == 0.0f
                if isRecharging
                    isRecharging = false
                    fore->addAction(new FadeOut(0.1f))
                    var seq: Sequence? = new Sequence()
                    seq->addAction(new FadeIn(0.1f))
                    seq->addAction(new FadeOut(0.1f))
                    flash->addAction(seq)

                    getSoundPool()->playEffect(UNIT_RECHARGED_SOUND)

    def override draw(): void
        Sprite`draw(self)
        if !isDisabled
            cost->draw()
        fore->draw()
        recharge->draw()
        flash->draw()

    def reset(): void
        timer = rechargeTime
        isRecharging = true
        fore->setOpacity(0.5f)
        getSoundPool()->playEffect(UNIT_CLICKED_SOUND)

    def setDisabled(_disabled: bool): void
        isDisabled = _disabled

    def redHightlightCost(): void
        var seq: Sequence? = new Sequence()
        seq->addAction(new TintTo(0xff4040, 0.0f))
        seq->addAction(new Wait(0.075f))
        seq->addAction(new TintTo(0xffffff, 0.0f))
        seq->addAction(new Wait(0.075f))
        seq->addAction(new TintTo(0xff4040, 0.0f))
        seq->addAction(new Wait(0.075f))
        seq->addAction(new TintTo(0xffffff, 0.0f))
        cost->addAction(seq)

def createUnitBar(code: int): UnitBar?
    if code == int(CharacterCode A00_BASE)
        return new UnitBar(BAR_WORKER, 0.01f, 100)
    elif code == int(CharacterCode A01_NORMAL)
        return new UnitBar(BAR_NORMAL, 1.0f, 100)
    elif code == int(CharacterCode B01_FIRE)
        return new UnitBar(BAR_FIRE, 10.0f, 150)
    elif code == int(CharacterCode B02_ICE)
        return new UnitBar(BAR_ICE, 5.0f, 50)
    elif code == int(CharacterCode B03_TREE)
        return new UnitBar(BAR_LEAF, 15.0f, 300)
    elif code == int(CharacterCode A05_BOMB)
        return new UnitBar(BAR_BOMB, 90.0f, 700)
    var res: UnitBar? = new UnitBar(BAR_LOCK, 0.01f, 0)
    res->setDisabled(true)
    return res