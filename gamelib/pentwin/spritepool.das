require daslib/media

module spritepool public

class SpritePool
    pool: table<string; Image>

    def getImage(filename: string): Image?
        var res: Image? = null
        find(pool, filename) <| $ (var found: Image? const)
            if found != null
                res = found
        if res == null
            pool[filename] <- create_image(filename)
            find(pool, filename) <| $ (var found: Image? const)
                if found != null
                    res = found
        return res

    def preloadImage(filename: string): void
        if !(pool |> key_exists(filename))
            pool[filename] <- create_image(filename)

var spPool: SpritePool? = new SpritePool()

def getImage(filename: string): Image?
    return spPool->getImage(filename)

def preloadImage(filename: string): void
    spPool->preloadImage(filename)
