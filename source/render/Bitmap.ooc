import ../geometry/Points
import ../UnsafeArray

import io/[FileWriter, BinarySequence]

RgbColor: cover {
    r, g, b: UInt8

    init: func@ (=r, =g, =b)
}

color: func (r, g, b: UInt8) -> RgbColor {
    (r, g, b) as RgbColor
}

Bitmap: class {
    width, height: Int
    data: UnsafeArray<RgbColor>

    pixelCount ::= width * height

    init: func (=width, =height) {
        data = UnsafeArray<RgbColor> new(width * height)
    }

    dumpTo: func (path: String) -> Bool {
        if (!data data || data length == 0) {
            return false
        }

        fHandle := FStream open(path, "wb")

        if (!fHandle) {
            return false
        }

        if (fHandle error() != 0) {
            fHandle close()
            return false
        }

        writer := BinarySequenceWriter new(FileWriter new(fHandle))
        writer endianness = Endianness little

        // BMP header

        // magic
        writer bytes("BM")

        // bytes per row without padding
        rowBytes := 3 * width
        // padding bytes we will need at the end of each row.
        rem := rowBytes % 4
        padding := match rem {
            case 0 =>
                0
            case =>
                4 - rem
        }

        // Size of the Bitmap file in bytes
        // BMP header is 14 bytes
        // DIB BITMAPCOREHEADER header is 12 bytes
        // 3 bytes per pixel * pixel count + padding bytes * rows is the rest
        size : UInt32 = 14 + 12 + 4 * pixelCount + padding * height

        // bmp file size in bytes
        writer u32(size)

        // 4 reserved bytes
        writer u32(0)

        // offset where the image data is found (in our case, directly after our 2 headers)
        writer u32(26)

        // DIB BITMAPCOREHEADER header

        // DWORD size of bytes required by the structure, 12 in our case
        writer u32(12)

        // WORD width of the bitmap
        writer u16(width)

        // WORD height of the bitmap
        writer u16(height)

        // WORD number of planes for the target device (always 1)
        writer u16(1)

        // WORD bits per pixel, 24 in our case
        writer u16(24)

        // We start at the bottom left corner, go right then upwards
        // and write BGR
        y := height - 1
        while (y >= 0) {
            for (x in 0 .. width) {
                color := data[x + y * height]
                writer u8(color b) . u8(color g) . u8(color r)
            }

            padding times(|| writer u8(0))

            y -= 1
        }

        fHandle close()
        true
    }

    writeAt: func (x, y: Int, color: RgbColor) {
        assert(x <= width)
        assert(y <= height)

        data[x + y * height] = color
    }

    getAt: func (x, y: Int) -> RgbColor {
        assert(x <= width)
        assert(y <= height)

        data[x + y * height]
    }

    operator [] (p: Point2d<Int>) -> RgbColor {
        getAt(p x, p y)
    }

    operator []= (p: Point2d<Int>, color: RgbColor) -> RgbColor {
        writeAt(p x, p y, color)
        color
    }

    operator [] (x: Int) -> ColumnAccess {
        (this, x) as ColumnAccess
    }
}

ColumnAccess: cover {
    bitmap: Bitmap
    x: Int

    operator [] (y: Int) -> RgbColor {
        bitmap getAt(x, y)
    }

    operator []= (y: Int, color: RgbColor) -> RgbColor {
        bitmap writeAt(x, y, color)
        color
    }
}
