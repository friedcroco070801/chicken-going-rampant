require fio
require daslib/json
require daslib/json_boost

module userdata public

var userData: UserData?

def getUserData(): UserData?&
    unsafe
        return userData

class UserData
    level: int = 1
    chars: array<int>

    def loadData()
        // Read json
        let filename = "gamelib/data/user.data"

        fopen(filename, "rb") <| $ (f)
            fread(f) <| $ (data)
                var error = ""
                var json = read_json(data, error)
                if json == null
                    panic("failed to parse {filename}, {error}\n")
                else
                    level = int((json as _object)["level"] as _number)
                    var charArr: array<JsonValue?> <- ((json as _object)["chars"] as _array)
                    for char in charArr
                        chars |> push(int(char as _number))
                unsafe
                    string_heap_collect()

    def saveData()
        // Read json
        let filename = "gamelib/data/user.data"

        fopen(filename, "wb") <| $ (f)
            var temp: array<JsonValue?>
            for char in chars
                temp |> push(JV(char))
            var json: JsonValue? = JV({{"level" => JV(level); "chars" => JV(temp)}})
            
            fwrite(f, write_json(json))
            unsafe
                string_heap_collect()

