require daslib/media

module soundpool public

class SoundPool
    pool: table<string; PcmSound>
    effectVolume: float = 1.0f
    backgroundVolume: float = 1.0f
    backgroundHandle: PlayingSoundHandle

    def playBackground(filename: string): void
        if backgroundHandle |> is_playing()
            backgroundHandle |> stop_sound()

        var res: PcmSound? = null
        find(pool, filename) <| $ (var found: PcmSound? const)
            if found != null
                res = found
        if res == null
            pool[filename] <- create_sound(filename)
            find(pool, filename) <| $ (var found: PcmSound? const)
                if found != null
                    res = found
        if res != null
            backgroundHandle = *res |> play_sound_loop(backgroundVolume)

    def stopBackgroundMusic()
        if backgroundHandle |> is_playing()
            backgroundHandle |> stop_sound()

    def playEffect(filename: string): void
        var res: PcmSound? = null
        find(pool, filename) <| $ (var found: PcmSound? const)
            if found != null
                res = found
        if res == null
            pool[filename] <- create_sound(filename)
            find(pool, filename) <| $ (var found: PcmSound? const)
                if found != null
                    res = found
        if res != null
            *res |> play_sound(effectVolume)

    def setBackgroundVolume(_volume: float)
        backgroundVolume = _volume
        if backgroundHandle |> is_playing()
            backgroundHandle |> set_sound_volume(_volume)

    def setEffectVolume(_volume: float)
        effectVolume = _volume

    def preloadSound(filename: string): void
        if !(pool |> key_exists(filename))
            pool[filename] <- create_sound(filename)

var soundPool: SoundPool? = new SoundPool()

def preloadSound(filename: string): void
    soundPool->preloadSound(filename)

def getSoundPool(): SoundPool?
    return soundPool