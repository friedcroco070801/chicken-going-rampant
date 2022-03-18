module constant public

let shared public
    CENTISEC = 0.01f
    LINE_START = 240.0f
    LINE_END = 1120.0f
    LINE_GROUND = 540.0f

enum public CharacterCode
    NONE
    A00_BASE
    A01_NORMAL
    A02_FIRE
    A03_ICE
    A04_TREE
    A05_BOMB
    A06_FIRETREE
    A07_ICETREE
    B01_FIRE
    B02_ICE
    B03_TREE
    E00_BASE
    E01_NORMAL
    E02_CAT
    E03_BIRD
    E04_CROCO
    E05_ELEPHANT

enum public AttackType
    NONE
    SINGLE
    AREA

enum public CharacterState
    IDLING
    MOVING
    ATTACKING