import Vectors

Point2d: cover template <T> {
    x, y: T

    init: func@ (=x, =y) 
}

Point3d: cover template <T> {
    x, y, z: T

    init: func@ (=x, =y, =z)

    operator + (other: Point3d<T>) -> Point3d<T> {
        (other x + x, other y + y, other z + z) as Point3d<T>
    }

    operator - (other: Point3d<T>) -> Point3d<T> {
        (x - other x, y - other y, z - other z) as Point3d<T>
    }

    operator * (num: T) -> Point3d<T> {
        (x * num, y * num, z * num) as Point3d<T>
    }

    // These are not necessary but a bit faster than letting the expressions unwarp to a = a +/- b 
    operator@ += (other: Point3d<T>) -> Point3d<T> {
        x += other x
        y += other y
        z += other z

        this
    }

    operator@ -= (other: Point3d<T>) -> Point3d<T> {
        x -= other x
        y -= other y
        z -= other z

        this
    }

    vec: func -> Vector3d<T> {
        (x, y, z) as Vector3d<T>
    }

    toString: func -> String {
        "point(#{x}, #{y}, #{z})"
    }
}

point: func (x, y, z: Double) -> Point3d<Double> {
    (x, y, z) as Point3d<Double>
}
