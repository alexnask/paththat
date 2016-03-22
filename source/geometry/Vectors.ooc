use math
import math

import Points

Vector3d: cover template <T> {
    x, y, z: T

    init: func@ (=x, =y, =z)

    length: func -> T {
        (x * x + y * y + z * z) sqrt()
    }

    normalize!: func@ {
        len := length()
        (x, y, z) = (x / len, y / len, z / len)
    }

    normalized: func -> This<T> {
        ret := (x, y, z) as Vector3d<T>
        ret normalize!()
        ret
    }

    cross: func (other: This<T>) -> This<T> {
        (y * other z - other y * z, z * other x - other z * x, x * other y - other x * y) as Vector3d<T>
    }

    dot: func (other: This<T> ) -> T {
        x * other x + y * other y + z * other z
    }

    pt: func -> Point3d<T> {
        (x, y, z) as Point3d<T>
    }

    rotateXZ!: func@ (theta: Double) {
        sine := theta sin()
        cosine := theta cos()

        temp := z
        
        z = z * cosine - x * sine
        x = temp * sine + x * cosine
    }

    rotateYZ!: func@ (theta: Double) {
        sine := theta sin()
        cosine := theta cos()

        temp := z
        
        z = z * cosine - y * sine
        y = temp * sine + y * cosine
    }

    rotateXY!: func@ (theta: Double) {
        sine := theta sin()
        cosine := theta cos()

        temp := x

        x = x * cosine - y * sine
        y = temp * sine + y * cosine
    }

    operator - (other: This<T>) -> This<T> {
        (x - other x, y - other y, z - other z) as This<T>
    }

    operator * (other: T) -> This<T> {
        (x * other, y * other, z * other) as This<T>
    }

    toString: func -> String {
        "vec(#{x}, #{y}, #{z})"
    }
}

vec: func (x, y, z: Double) -> Vector3d<Double> {
    (x, y, z) as Vector3d<Double>
}
