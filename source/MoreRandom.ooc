import math/Random
import structs/List

extend Random {
    percentage: static func -> Float {
        Random random() as Float / RAND_MAX
    }
}
