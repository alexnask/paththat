import ../UnsafeArray
import Mesh, Surfaces, Ray, Points
import ../trace/Camera

PotentialIntersection: cover {
    t: Double
    surface: Surface

    point: func(ray: Ray) -> Point3d<Double> {
        ray origin + (ray direction * t) pt()
    }

    _quicksort: static func(arr: UnsafeArray<This>, left, right: Int) {
        i := left
        j := right

        pivot := arr[(left + right)/2] t

        while (i <= j) {
            while (arr[i] t < pivot) {
                i += 1
            }

            while (arr[j] t > pivot) {
                j -= 1
            }

            if (i <= j) {
                temp := arr[i]
                arr[i] = arr[j]
                arr[j] = temp

                i += 1
                j -= 1
            }
        }

        if (left < j) {
            _quicksort(arr, left, j)
        }

        if (i < right) {
            _quicksort(arr, i, right)
        }
    }
}

Scene: class {
    surfaces: UnsafeArray<Surface>
    intersectingSurfaces: UnsafeArray<PotentialIntersection>

    // This is pretty much only needed to animate (have a concept of objects in the scene)
    meshes: UnsafeArray<Mesh>

    // The light surfaces belong to 'surfaces' too
    lights: UnsafeArray<Mesh>

    camera: Camera

    init: func (surfacePtr: Surface*, surfaceLen: Int, meshPtr: Mesh*, meshLen: Int, lightPtr: Mesh*, lightLen: Int, =camera) {
        surfaces = (surfacePtr, surfaceLen) as UnsafeArray<Surface>
        meshes = (meshPtr, meshLen) as UnsafeArray<Mesh>
        lights = (lightPtr, lightLen) as UnsafeArray<Mesh>

        intersectingSurfaces = UnsafeArray<PotentialIntersection> new(surfaceLen)
        intersectingSurfaces length = 0
    }

    // Visibility test!
    pointsVisible?: func (p1, p2: Point3d<Double>) -> Bool {
        ray := (p1, (p2 - p1) vec() normalized()) as Ray

        interPoint: Point3d<Double>
        surface: Surface = null

        findFirstIntersection(ray, interPoint&, surface&)

        if (!surface) {
            return true
        }

        tmax := (p2 - p1) vec() length()
        tinter := (interPoint - p1) vec() length()

        return tinter > tmax
    }

    // If we don't touch 'point' and 'surface', there is no intersection
    findFirstIntersection: func(ray: Ray, point: Point3d<Double>*, surface: Surface*) {
        epsilon: static const Double = 0.0001

        for (i in 0 .. surfaces length) {
            surface := surfaces[i]

            denom := surface normal dot(ray direction)

            if (denom > epsilon || denom < -epsilon) {
                t := (surface origin() - ray origin) vec() dot(surface normal) / denom

                if (t >= 0) {
                    intersectingSurfaces[intersectingSurfaces length] = (t, surface) as PotentialIntersection
                    intersectingSurfaces length += 1
                }
            }
        }

        PotentialIntersection _quicksort(intersectingSurfaces, 0, intersectingSurfaces length - 1)

        for (i in 0 .. intersectingSurfaces length) {
            pt := intersectingSurfaces[i] point(ray)

            if (intersectingSurfaces[i] surface contains?(pt)) {
                point@ = pt
                surface@ = intersectingSurfaces[i] surface
                break
            }
        }

        intersectingSurfaces length = 0
    }
}
