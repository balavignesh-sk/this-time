import SwiftUI

struct PromiseBoy: View {
    var body: some View {
        Canvas { context, size in
            // Slightly asymmetric curves keep the character feeling like a notebook sketch.
            let transform = CGAffineTransform(scaleX: size.width / 150, y: size.height / 190)
            var outline = Path()
            outline.move(to: CGPoint(x: 42, y: 135))
            outline.addCurve(to: CGPoint(x: 32, y: 70),
                             control1: CGPoint(x: 26, y: 118), control2: CGPoint(x: 24, y: 90))
            outline.addCurve(to: CGPoint(x: 78, y: 30),
                             control1: CGPoint(x: 34, y: 41), control2: CGPoint(x: 52, y: 27))
            outline.addCurve(to: CGPoint(x: 117, y: 77),
                             control1: CGPoint(x: 106, y: 29), control2: CGPoint(x: 119, y: 50))
            outline.addCurve(to: CGPoint(x: 106, y: 137),
                             control1: CGPoint(x: 125, y: 107), control2: CGPoint(x: 117, y: 128))
            outline.addCurve(to: CGPoint(x: 42, y: 135),
                             control1: CGPoint(x: 91, y: 148), control2: CGPoint(x: 59, y: 145))
            context.stroke(outline.applying(transform), with: .color(AppColors.textPrimary),
                           style: StrokeStyle(lineWidth: 1.8, lineCap: .round, lineJoin: .round))

            var details = Path()
            // Loose arms and feet.
            details.move(to: CGPoint(x: 31, y: 95))
            details.addQuadCurve(to: CGPoint(x: 18, y: 119), control: CGPoint(x: 17, y: 105))
            details.move(to: CGPoint(x: 119, y: 94))
            details.addQuadCurve(to: CGPoint(x: 132, y: 116), control: CGPoint(x: 130, y: 100))
            details.move(to: CGPoint(x: 57, y: 143))
            details.addLine(to: CGPoint(x: 54, y: 163))
            details.addLine(to: CGPoint(x: 44, y: 164))
            details.move(to: CGPoint(x: 91, y: 144))
            details.addLine(to: CGPoint(x: 94, y: 162))
            details.addLine(to: CGPoint(x: 104, y: 163))
            // A small, quiet smile.
            details.move(to: CGPoint(x: 67, y: 96))
            details.addQuadCurve(to: CGPoint(x: 82, y: 95), control: CGPoint(x: 75, y: 102))
            context.stroke(details.applying(transform), with: .color(AppColors.textPrimary),
                           style: StrokeStyle(lineWidth: 1.7, lineCap: .round, lineJoin: .round))
            for eye in [CGRect(x: 58, y: 79, width: 3, height: 4),
                        CGRect(x: 87, y: 78, width: 3, height: 4)] {
                context.fill(Path(ellipseIn: eye).applying(transform), with: .color(AppColors.textPrimary))
            }
        }
    }
}
