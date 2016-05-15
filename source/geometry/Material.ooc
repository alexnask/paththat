import Points

// TODO: Extend these to accept (U, V) parameters
// Have some standard way to get UV

Material: abstract class {
    light?: abstract func -> Bool

    // Fraction of reflected light
    albedo: abstract func -> Float

    // Color a material emmits.
    // Materials that are not lights may still emit
    emmitance: abstract func -> Point3d<Double>

    // Color of the actual material
    color: abstract func -> Point3d<Double>

    def := static PhongMaterial new(point(1.0, 1.0, 1.0), point(1.0, 1.0, 1.0), point(1.0, 1.0, 1.0), 0.0) as Material
}

PhongMaterial: class extends Material {
    ambient, diffuse, specular: Point3d<Double>
    transparency: Float

    init: func (=ambient, =diffuse, =specular, =transparency)
    init: func~empty

    // TODO
    albedo: func -> Float {
        0.5
    }

    emmitance: func -> Point3d<Double> {
        point(0, 0, 0)
    }

    color: func -> Point3d<Double> {
        ambient
    }

    light?: func -> Bool { false }
}

LightMaterial: class extends Material {
    lightColor: Point3d<Double>

    light?: func -> Bool { true }

    albedo: func -> Float {
        0.0
    }

    emmitance: func -> Point3d<Double> {
        lightColor
    }

    color: func -> Point3d<Double> {
        point(0, 0, 0)
    }

    init: func (=lightColor)
}
