import Foundation
import CoreGraphics
import ImageIO
import CoreText
import AppKit
import UniformTypeIdentifiers

// Renders the Sverto logo (ring + diagonal + dot, from android ic_sverto_logo.xml) into
// 1024x1024 app icons for prod (green) and dev (orange, with a DEV ribbon) and a vector PDF logo.

func drawLogo(_ ctx: CGContext, in rect: CGRect, color: CGColor) {
    let scale = rect.width / 512
    ctx.saveGState()
    ctx.translateBy(x: rect.minX, y: rect.minY)
    ctx.scaleBy(x: scale, y: scale)
    ctx.setStrokeColor(color)
    ctx.setFillColor(color)
    ctx.setLineWidth(28)
    ctx.setLineCap(.round)
    ctx.strokeEllipse(in: CGRect(x: 110, y: 110, width: 292, height: 292))
    ctx.move(to: CGPoint(x: 104, y: 512 - 334))
    ctx.addLine(to: CGPoint(x: 408, y: 512 - 178))
    ctx.strokePath()
    ctx.fillEllipse(in: CGRect(x: 228, y: 228, width: 56, height: 56))
    ctx.restoreGState()
}

func writePNG(_ image: CGImage, to path: String) {
    let url = URL(fileURLWithPath: path) as CFURL
    guard let dest = CGImageDestinationCreateWithURL(url, UTType.png.identifier as CFString, 1, nil) else { fatalError("dest") }
    CGImageDestinationAddImage(dest, image, nil)
    CGImageDestinationFinalize(dest)
}

func makeIcon(background: CGColor, ribbon: String?, path: String) {
    let size = 1024
    let cs = CGColorSpace(name: CGColorSpace.sRGB)!
    let ctx = CGContext(data: nil, width: size, height: size, bitsPerComponent: 8, bytesPerRow: 0, space: cs, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    ctx.setFillColor(background)
    ctx.fill(CGRect(x: 0, y: 0, width: size, height: size))
    let inset: CGFloat = 128
    drawLogo(ctx, in: CGRect(x: inset, y: inset, width: CGFloat(size) - inset * 2, height: CGFloat(size) - inset * 2), color: CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 1))
    if let ribbon {
        ctx.setFillColor(CGColor(srgbRed: 0.1, green: 0.1, blue: 0.1, alpha: 0.85))
        ctx.fill(CGRect(x: 0, y: 0, width: size, height: 200))
        let attrs: [NSAttributedString.Key: Any] = [
            .font: CTFontCreateWithName("HelveticaNeue-Bold" as CFString, 150, nil),
            .foregroundColor: CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 1),
        ]
        let line = CTLineCreateWithAttributedString(NSAttributedString(string: ribbon, attributes: attrs))
        let bounds = CTLineGetBoundsWithOptions(line, [])
        ctx.textPosition = CGPoint(x: (CGFloat(size) - bounds.width) / 2, y: 45)
        CTLineDraw(line, ctx)
    }
    writePNG(ctx.makeImage()!, to: path)
}

func makeLogoPDF(path: String) {
    var box = CGRect(x: 0, y: 0, width: 512, height: 512)
    let ctx = CGContext(URL(fileURLWithPath: path) as CFURL, mediaBox: &box, nil)!
    ctx.beginPDFPage(nil)
    drawLogo(ctx, in: box, color: CGColor(srgbRed: 0x15 / 255, green: 0xBA / 255, blue: 0x81 / 255, alpha: 1))
    ctx.endPDFPage()
    ctx.closePDF()
}

let out = CommandLine.arguments[1]
makeIcon(background: CGColor(srgbRed: 0x00 / 255, green: 0x98 / 255, blue: 0x69 / 255, alpha: 1), ribbon: nil, path: "\(out)/AppIcon.appiconset/icon.png")
makeIcon(background: CGColor(srgbRed: 0xFF / 255, green: 0x6B / 255, blue: 0x00 / 255, alpha: 1), ribbon: "DEV", path: "\(out)/AppIcon-Dev.appiconset/icon.png")
makeLogoPDF(path: "\(out)/Logo.imageset/logo.pdf")
print("icons written to \(out)")
