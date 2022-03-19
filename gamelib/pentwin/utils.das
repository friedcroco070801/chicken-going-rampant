require daslib/media
require random

module utils public

var private
    seed = random_seed(int(ref_time_ticks()))

def randFloat01(): float
    return random_float(seed)

def randIntM11(): int
    if randFloat01() <= 0.5f
        return 1
    else
        return -1