import ../geometry/Ray

Lens: abstract class {
    // Takes a ray generated from the camera and x and y percentages of the pixel it was generated from
    // May mutate the ray as it sees fit.
    distortRay: abstract func (ray: Ray@, x, y: Float)
}

// Does not distort rays at all
SimpleLens: class extends Lens {
    init: func

    distortRay: func(ray: Ray@, x, y: Float)
}
