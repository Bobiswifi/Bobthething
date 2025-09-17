import SwiftUI

enum BroccoliEffect: Equatable {
    case wobble, pulse, spin, float, colorShift, explode
}

struct BroccoliView: View {
    var effect: BroccoliEffect?

    @State private var wobbleAmount: Double = 0
    @State private var scale: CGFloat = 1
    @State private var rotation: Double = 0
    @State private var offsetY: CGFloat = 0
    @State private var hue: Double = 0
    @State private var pieces: [BroccoliPiece] = []

    var body: some View {
        ZStack {
            // shadow card
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.ultraThinMaterial)
                .frame(width: 260, height: 340)
                .shadow(color: Color.black.opacity(0.12), radius: 20, x: 0, y: 8)

            VStack(spacing: 6) {
                Spacer()
                // stalk
                Capsule()
                    .fill(LinearGradient(colors: [Color(#colorLiteral(red: 0.435, green: 0.612, blue: 0.294, alpha: 1)), Color(#colorLiteral(red: 0.357, green: 0.502, blue: 0.235, alpha: 1))], startPoint: .top, endPoint: .bottom))
                    .frame(width: 48, height: 120)
                    .offset(y: 30 + offsetY)

                // head
                ZStack {
                    ForEach(0..<6) { i in
                        Circle()
                            .fill(headColor.opacity(1.0 - Double(i) * 0.06))
                            .frame(width: 200 - CGFloat(i) * 18, height: 120 - CGFloat(i) * 12)
                            .offset(x: CGFloat(i - 3) * 6 * CGFloat(sin(wobbleAmount + Double(i))), y: CGFloat(-i) * 4)
                    }

                    // smile
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.9))
                        .frame(width: 90, height: 16)
                        .offset(y: 12)
                        .mask(
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 90, height: 16)
                        )
                        .opacity(0.9)
                }
                .scaleEffect(scale)
                .rotationEffect(.degrees(rotation))
                .hueRotation(.degrees(hue))
                .offset(y: offsetY)

                Spacer()
            }
            .frame(width: 220, height: 300)

            // pieces for explode
            ForEach(pieces) { piece in
                PieceView(piece: piece)
            }
        }
        .onChange(of: effect) { effect in
            // announce change for VoiceOver
            if let effect = effect {
                let announcement = "Broccoli: \(announcementText(for: effect))"
                UIAccessibility.post(notification: .announcement, argument: announcement)
            }
            runEffect(effect)
        }
    }

    func announcementText(for e: BroccoliEffect) -> String {
        switch e {
        case .wobble: return "wobbling"
        case .pulse: return "taking a deep breath"
        case .spin: return "spinning happily"
        case .float: return "floating"
        case .colorShift: return "changing colors"
        case .explode: return "bursting into pieces"
        }
    }

    var headColor: Color {
        Color(hue: 0.28 + hue / 360.0, saturation: 0.6, brightness: 0.65)
    }

    func runEffect(_ e: BroccoliEffect?) {
        // reset
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            wobbleAmount = 0
            scale = 1
            rotation = 0
            offsetY = 0
            hue = 0
            pieces = []
        }

        guard let e = e else { return }

        switch e {
        case .wobble:
            withAnimation(.interpolatingSpring(stiffness: 120, damping: 8)) {
                wobbleAmount = .pi * 2
            }
            // oscillate back to 0
            withAnimation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                wobbleAmount = .pi / 6
            }

        case .pulse:
            withAnimation(.easeInOut(duration: 0.18).repeatCount(3, autoreverses: true)) {
                scale = 1.18
            }

        case .spin:
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                rotation = 360
                scale = 1.08
            }

        case .float:
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                offsetY = -12
            }

        case .colorShift:
            withAnimation(.linear(duration: 1.0).repeatCount(6, autoreverses: true)) {
                hue = 160
            }

        case .explode:
            // spawn pieces
            var newPieces: [BroccoliPiece] = []
            for i in 0..<12 {
                newPieces.append(BroccoliPiece(id: i, angle: Double(i) / 12.0 * 2 * .pi))
            }
            pieces = newPieces
            // animate pieces outward
            for i in pieces.indices {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.02) {
                    withAnimation(.interpolatingSpring(stiffness: 90, damping: 8).speed(1.2)) {
                        pieces[i].explode = true
                    }
                }
            }

            // fade pieces after a bit
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                withAnimation(.easeOut(duration: 0.6)) {
                    pieces = []
                }
            }
        }
    }
}

struct BroccoliPiece: Identifiable {
    let id: Int
    var angle: Double
    var explode: Bool = false
}

struct PieceView: View {
    let piece: BroccoliPiece

    var body: some View {
        Circle()
            .fill(Color.green)
            .frame(width: 18, height: 18)
            .offset(x: piece.explode ? cos(piece.angle) * 140 : 0, y: piece.explode ? sin(piece.angle) * -80 : 0)
            .scaleEffect(piece.explode ? 0.9 : 1)
            .opacity(piece.explode ? 1 : 0.0)
            .animation(.easeOut(duration: 0.9), value: piece.explode)
    }
}

struct BroccoliView_Previews: PreviewProvider {
    static var previews: some View {
        BroccoliView(effect: .wobble)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
