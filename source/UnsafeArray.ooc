// Needs these because rock doesn't generate includes for types geenrated by the templates
import render/Bitmap
import geometry/[Surfaces, Points, Mesh, Scene]

UnsafeArray: cover template <T> {
    data: T*
    length: Int

    init: func@ (=length) {
        data = gc_malloc(T size * length)
    }

    operator [] (i: Int) -> T {
        data[i]
    }

    operator@ []= (i: Int, t: T) -> T {
        data[i] = t
    }
}
