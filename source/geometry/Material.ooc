import ../render/Bitmap

// TODO: This is just the way OBJ does stuff, we should be able to define BSDFs with other parameters
Material: class {
    ambient, diffuse, specular: RgbColor
    transparency: Float

    init: func(=ambient, =diffuse, =specular, =transparency)
    init: func~empty

    def := static This new(color(255, 255, 255), color(255, 255, 255), color(255, 255, 255), 0.0) 
}
