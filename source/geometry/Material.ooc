import Points

// TODO: This is just the way OBJ does stuff, we should be able to define BSDFs with other parameters
Material: class {
    ambient, diffuse, specular: Point3d<Double>
    transparency: Float

    init: func(=ambient, =diffuse, =specular, =transparency)
    init: func~empty

    def := static This new(point(1.0, 1.0, 1.0), point(1.0, 1.0, 1.0), point(1.0, 1.0, 1.0), 0.0) 
}
