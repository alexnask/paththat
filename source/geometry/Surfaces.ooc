import Points, Vectors, Material
import ../[UnsafeArray, MoreRandom]

import math/Random
import math

_sameSide: func (a, b, c, d: Point3d<Double>) -> Bool {
    cross1 := (d - c) vec() cross((a - c) vec())
    cross2 := (d - c) vec() cross((b - c) vec())
    
    if (cross1 dot(cross2) >= 0) {
        return true
    }
    false
}

Surface: abstract class {
    // These coordinates are used as a conceptual bounding box to exclude intersections fast.
    xmin, xmax, ymin, ymax, zmin, zmax: Double

    material: Material
    normal: Vector3d<Double>

    moveBy: abstract func (p: Point3d<Double>)
    contains?: abstract func(p: Point3d<Double>) -> Bool
    randomPoint: abstract func -> Point3d<Double>

    minMax: func (p: Point3d<Double>) {
        if (p x < xmin) {
            xmin = p x
        }

        if (p x > xmax) {
            xmax = p x
        }

        if (p y < ymin) {
            ymin = p y
        }

        if (p y > ymax) {
            ymax = p y
        }

        if (p z < zmin) {
            zmin = p z
        }

        if (p z > zmax) {
            zmax = p z
        }
    }

    inBoundingBox?: func (p: Point3d<Double>) -> Bool {
        epsilon: static const Double = 0.0001

        p x + epsilon >= xmin && p x - epsilon <= xmax && p y + epsilon >= ymin && p y - epsilon <= ymax && p z + epsilon >= zmin && p z - epsilon <= zmax
    }

    // Returns some point of the surface we can use as an origin (for example, as a meshe's position)
    origin: abstract func -> Point3d<Double>
}

Triangle: class extends Surface {
    p1, p2, p3: Point3d<Double>

    init: func (=p1, =p2, =p3, =material) {
        // Calculate normal
        normal = (p2 - p1) vec() cross((p3 - p1) vec()) normalized()

        xmin = xmax = p1 x
        ymin = ymax = p1 y
        zmin = zmax = p1 z

        minMax(p2)
        minMax(p3)
    }

    moveBy: func (p: Point3d<Double>) {
        p1 += p
        p2 += p
        p3 += p
    }

    contains?: func (p: Point3d<Double>) -> Bool {
        if (!inBoundingBox?(p)) {
            return false
        }

        _sameSide(p, p1, p2, p3) && _sameSide(p, p2, p1, p3)
    }

    origin: func -> Point3d<Double> {
        p1
    }

    randomPoint: func -> Point3d<Double> {
        r1 := Random percentage()
        r2 := Random percentage()

        sq := r1 sqrt()

        p1 * (1 - sq) + p2 * (sq * (1 - r2)) + p3 * (sq * r2)
    }
}

ConvexPolygon: class extends Surface {
    points: UnsafeArray<Point3d<Double>>

    init: func (pointData: Point3d<Double>*, pointLen: Int, =material) {
        assert(pointLen >= 3)

        points = (pointData, pointLen) as UnsafeArray<Point3d<Double>>

        normal = (points[1] - points[0]) vec() cross((points[2] - points[0]) vec()) normalized()

        xmin = xmax = points[0] x
        ymin = ymax = points[0] y
        zmin = zmax = points[0] z

        for (i in 1 .. pointLen) {
            minMax(points[i])
        }
    }

    moveBy: func (p: Point3d<Double>) {
        for (i in 0 .. points length) {
            points[i] = points[i] + p
        }
    }

    contains?: func (p: Point3d<Double>) -> Bool {
        if (!inBoundingBox?(p)) {
            return false
        }

        // For every vertex, check p is on the same side as another edge (and ofc short circuit this)
        len := points length
        for (i in 0 .. len) {
            vertex := points[i]
            // Get our other two vertices
            vertex2 := points[(i + 1) % len]
            vertex3 := points[(i + 2) % len]

            if (!_sameSide(p, vertex, vertex2, vertex3)) {
                return false
            }
        }
        true
    }

    origin: func -> Point3d<Double> {
        points[0]
    }

    randomPoint: func -> Point3d<Double> {
        // Ok, so we chose two random edges, take two random points on them
        // and then a random point on the line these two points define
        vertex1_idx := Random randRange(0, points length)
        vertex2_idx := Random randRange(0, 2) == 0 ? (vertex1_idx + 1) % points length : vertex1_idx - 1
        if (vertex2_idx < 0) {
            vertex2_idx += points length
        }

        // We could allow for 1 point overlap but my brain hurts right now
        vertex3_idx := Random randRange(0, points length - 2)

        if (vertex3_idx >= vertex1_idx) {
            vertex3_idx += 1
        }

        if (vertex3_idx >= vertex2_idx) {
            vertex3_idx += 1
        }

        vertex4_idx := Random randRange(0, 2) == 0 ? (vertex3_idx + 1) % points length : vertex3_idx - 1
        if (vertex4_idx < 0) {
            vertex2_idx += points length
        }

        edge1_pt_percent := Random percentage()

        v1 := points[vertex1_idx]
        v2 := points[vertex2_idx]

        pt1 := v1 + (v2 - v1) * edge1_pt_percent

        edge2_pt_percent := Random percentage()

        v3 := points[vertex3_idx]
        v4 := points[vertex4_idx]

        pt2 := v3 + (v4 - v3) * edge2_pt_percent

        pt_percent := Random percentage()

        pt1 + (pt2 - pt1) * pt_percent
    }
}
