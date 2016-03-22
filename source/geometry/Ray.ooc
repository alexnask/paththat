import Points, Vectors

Ray: cover {
    origin: Point3d<Double>
    direction: Vector3d<Double>

    init: func (=origin, =direction)

    toString: func -> String {
        "ray(origin: #{origin}, direction: #{direction})"
    }
}
