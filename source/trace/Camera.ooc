import Lens
import ../render/Bitmap
import ../geometry/[Points, Vectors, Surfaces, Ray]

import math

Camera: class {
    position: Point3d<Double>
    direction: Vector3d<Double>

    lens: Lens
    // TODO: Camera should not own a bitmap, rather have some trace method that takes one and renders to it.
    _bitmap: Bitmap

    // All angles are in radians
    horizontalFOV: Double
    verticalFOV: Double

    pixelWidth ::= _bitmap width
    pixelHeight ::= _bitmap height

    init: func (=position, =direction, =_bitmap, =lens, =horizontalFOV) {
        verticalFOV = horizontalFOV * pixelHeight / pixelWidth
    }

    // Generates the ray according to FOV and applies Lens
    rayFor: func (x, y: Int) -> Ray {
        assert(x < pixelWidth)
        assert(y < pixelHeight)

        ray_x := direction x + tan(horizontalFOV/2) * (2 * x - pixelWidth) / pixelWidth
        ray_y := direction y + tan(verticalFOV/2) * (2 * y - pixelHeight) / pixelHeight

        ray := (position, vec(ray_x, ray_y, direction z) normalized()) as Ray
        lens distortRay(ray&, x as Float / (pixelWidth - 1), y as Float / (pixelHeight - 1))
        ray
    }
}
