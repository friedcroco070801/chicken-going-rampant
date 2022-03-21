require fio
require daslib/json
require daslib/json_boost

module leveldata public

class EnemyData
    startTime: int = 0 // centisec, 0 if never spawn
    interval: int = 1000 // centisec between loop
    loop: int = 0 // 9999 if forever
    code: int = 201

    def EnemyData(_startTime: int; _interval: int; _loop: int; _code: int)
        startTime = _startTime
        interval = _interval
        loop = _loop
        code = _code

class LevelData
    level: int = 1
    enemyBaseHP: int = 0
    enemies: array<EnemyData?>

    def finalize
        for enemy in enemies
            unsafe
                delete enemy

    def LevelData(_level: int)
        level = _level

        // Read json
        let filename = "gamelib/data/level{level}.json"

        fopen(filename, "rb") <| $ (f)
            fread(f) <| $ (data)
                var error = ""
                var json = read_json(data, error)
                if json == null
                    panic("failed to parse {filename}, {error}\n")
                else
                    enemyBaseHP = int((json as _object)["enemyBaseHP"] as _number)
                    var enemyArr: array<JsonValue?> <- ((json as _object)["enemies"] as _array)
                    for enemy in enemyArr
                        let startTime = int((enemy as _object)["startTime"] as _number)
                        let interval = int((enemy as _object)["interval"] as _number)
                        let loop = int((enemy as _object)["loop"] as _number)
                        let code = int((enemy as _object)["code"] as _number)
                        enemies |> push(new EnemyData(startTime, interval, loop, code))
                unsafe
                    string_heap_collect()

    def updateAndGetEnemiesAt(cs: int): array<int>
        var res: array<int>
        for enemy in enemies
            if cs >= enemy.startTime && (cs - enemy.startTime) % enemy.interval == 0 && enemy.loop > 0
                res |> push(enemy.code)
                if enemy.loop < 9999
                    enemy.loop--
        return <- res