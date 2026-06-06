import Cocoa

let args = CommandLine.arguments
if args.count < 3 {
    print("Usage: swift fix_icon.swift <input.png> <output.png>")
    exit(1)
}

let inputPath = args[1]
let outputPath = args[2]

guard let inputImage = NSImage(contentsOfFile: inputPath) else {
    print("Could not read input image")
    exit(1)
}

let size = inputImage.size
let cornerRadius = size.width * 0.225

let resultImage = NSImage(size: size)
resultImage.lockFocus()

// Clear background
NSColor.clear.set()
NSRect(origin: .zero, size: size).fill()

// Create mask path
let rect = NSRect(origin: .zero, size: size)
let path = NSBezierPath(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius)
path.addClip()

// Draw image much larger to completely hide background edges (1.15x scale)
let scale: CGFloat = 1.15
let drawWidth = size.width * scale
let drawHeight = size.height * scale
let drawX = -(drawWidth - size.width) / 2.0
let drawY = -(drawHeight - size.height) / 2.0

let drawRect = NSRect(x: drawX, y: drawY, width: drawWidth, height: drawHeight)
inputImage.draw(in: drawRect)

resultImage.unlockFocus()

guard let tiffData = resultImage.tiffRepresentation,
      let bitmapImage = NSBitmapImageRep(data: tiffData),
      let pngData = bitmapImage.representation(using: .png, properties: [:]) else {
    print("Failed to generate PNG data")
    exit(1)
}

try? pngData.write(to: URL(fileURLWithPath: outputPath))
print("Successfully saved scaled and masked image to \(outputPath)")
