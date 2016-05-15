import render/Bitmap
import trace/[Camera, Lens]
import geometry/[Surfaces, ObjLoader, Mesh, Points, Vectors, Scene, Ray, Material]
import ../[MoreRandom, UnsafeArray]

import math/Random
import structs/ArrayList

PointSurface: cover {
    point: Point3d<Double>
    surface: Surface
    probability: Float

    init: func@ (=point, =surface, =probability)
}

BidirectionalTracer: class {
    trace: static func (scene: Scene, camera: Camera, spp: Int) {
        bm := camera _bitmap
        // The total (sum of camera and light) path length (excluding the shadow ray)
        path_length := 4

        // This is used to exclude some pretty bad contributions
        minimum_eye_path_length := 2

        eye_path := UnsafeArray<PointSurface> new(path_length)
        light_path := UnsafeArray<PointSurface> new(path_length - minimum_eye_path_length)

        // TODO: subsamples, perhaps antialiasing

        for (x in 0 .. bm width) {
            for (y in 0 .. bm height) {
                // TODO: Ideally, subsamples?
                ray := camera rayFor(x, y)

                colorPoint := point(0, 0, 0)

                for (k in 0 .. spp) {

                    // Generate eye path
                    eye_count := 0
                    while (eye_count < path_length) {
                        point: Point3d<Double>
                        surface := null as Surface

                        scene findFirstIntersection(ray, point&, surface&)

                        if (!surface) {
                            break
                        }

                        probability := match (eye_count >= minimum_eye_path_length) {
                            case true =>
                                surface material albedo()
                            case =>
                                1.0
                        }

                        eye_path[eye_count] = PointSurface new(point, surface, probability)
                        eye_count += 1

                        if (probability < 1.0) {
                            // Efficiency-optimized Russian roulette
                            if (Random percentage() > probability) {
                                break
                            }
                        }

                        // Calculate our new ray!
                        // ray = ...
                    }

                    if (eye_count > 0) {
                        // For now, return last point color
                        colorPoint += eye_path[eye_count - 1] surface material color() * (1.0 / spp)
                    }

                    if (eye_count < path_length) {
                        // So, at some point we stopped getting intersections, just get to the next sample
                        continue
                    }

                    // We hit something!
                    // colorPoint += (surface material emmitance() + surface material color()) * (1.0/spp)
                }

                bm writeAt(x, y, RgbColor fromColorPoint(colorPoint))
            }
        }
    }
}