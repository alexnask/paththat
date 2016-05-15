import Points, Vectors

Ray: cover {
    origin: Point3d<Double>
    direction: Vector3d<Double>

    init: func (=origin, =direction)

    fromPoints: static func (p1, p2: Point3d<Double>) -> Ray {
        (p1, (p2 - p1) vec() normalized()) as Ray
    }

    toString: func -> String {
        "ray(origin: #{origin}, direction: #{direction})"
    }
}
