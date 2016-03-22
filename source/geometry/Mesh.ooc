import ../UnsafeArray
import Surfaces
import ../geometry/Points

Mesh: class {
    surfaces: UnsafeArray<Surface>

    init: func (surfaceData: Surface*, surfaceLen: Int) {
        surfaces = (surfaceData, surfaceLen) as UnsafeArray<Surface>
    }

    moveBy: func (p: Point3d<Double>) {
        for (i in 0 .. surfaces length) {
            surfaces[i] moveBy(p)
        }
    }

    origin ::= surfaces[0] origin()
}
