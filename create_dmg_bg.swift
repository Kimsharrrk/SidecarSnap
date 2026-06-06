import Cocoa

let args = CommandLine.arguments
if args.count < 2 {
    print("Usage: swift create_dmg_bg.swift <output.png>")
    exit(1)
}
let outputPath = args[1]

let width: CGFloat = 600
let height: CGFloat = 400
let size = CGSize(width: width, height: height)

let image = NSImage(size: size)
image.lockFocus()

// Left half - Dark Blue (#0E1528)
let leftRect = NSRect(x: 0, y: 0, width: width/2, height: height)
NSColor(calibratedRed: 0.05, green: 0.08, blue: 0.16, alpha: 1.0).set()
leftRect.fill()

// Right half - White/Light Gray (#F5F5F7)
let rightRect = NSRect(x: width/2, y: 0, width: width/2, height: height)
NSColor(calibratedRed: 0.96, green: 0.96, blue: 0.97, alpha: 1.0).set()
rightRect.fill()

// Draw Arrow in the middle
let arrowPath = NSBezierPath()
let centerX = width / 2
let centerY = height / 2

// Arrow body
arrowPath.move(to: NSPoint(x: centerX - 40, y: centerY + 10))
arrowPath.line(to: NSPoint(x: centerX + 10, y: centerY + 10))
arrowPath.line(to: NSPoint(x: centerX + 10, y: centerY + 25))
// Arrow tip
arrowPath.line(to: NSPoint(x: centerX + 40, y: centerY))
arrowPath.line(to: NSPoint(x: centerX + 10, y: centerY - 25))
// Arrow body bottom
arrowPath.line(to: NSPoint(x: centerX + 10, y: centerY - 10))
arrowPath.line(to: NSPoint(x: centerX - 40, y: centerY - 10))
arrowPath.close()

// Fill with nice subtle color (e.g. system red or dark gray)
NSColor(calibratedRed: 0.9, green: 0.2, blue: 0.2, alpha: 1.0).set() // Red arrow as user sketched
arrowPath.fill()

NSColor.white.setStroke()
arrowPath.lineWidth = 2.0
arrowPath.stroke()

image.unlockFocus()

guard let tiffData = image.tiffRepresentation,
      let bitmapImage = NSBitmapImageRep(data: tiffData),
      let pngData = bitmapImage.representation(using: .png, properties: [:]) else {
    print("Failed to generate PNG data")
    exit(1)
}

try? pngData.write(to: URL(fileURLWithPath: outputPath))
print("Successfully saved DMG background to \(outputPath)")
