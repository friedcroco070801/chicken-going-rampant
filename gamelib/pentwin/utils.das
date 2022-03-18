require daslib/media
require random

module utils public

var private
    seed = random_seed(0)

def randFloat01(): float
    return random_float(seed)

def randIntM11(): int
    if randFloat01() <= 0.5f
        return 1
    else
        return -1