import SwiftUI

struct ConfettiView: View {
    @State private var emitter = [ConfettiBit]()
    
    // Define colors as a static constant to avoid recreation
    private static let confettiColors: [Color] = [.red, .yellow, .green, .pink, .blue, .orange]
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(emitter) { bit in
                    ConfettiBitView(bit: bit)
                }
            }
            .onAppear { emit(in: geo.size) }
        }
    }
    
    func emit(in size: CGSize) {
        // Clear existing bits
        emitter.removeAll(keepingCapacity: true)
        
        // Create new bits
        for i in 0..<22 {
            var bit = ConfettiBit(id: i)
            bit.x = size.width * 0.5
            bit.y = size.height * 0.35
            bit.vx = Double.random(in: -150 ... 150)
            bit.vy = Double.random(in: -420 ... -120)
            bit.spin = Double.random(in: -6 ... 6)
            bit.color = Self.confettiColors.randomElement() ?? .yellow
            emitter.append(bit)
        }
    }
}

struct ConfettiBit: Identifiable {
    let id: Int
    var x: CGFloat = 0
    var y: CGFloat = 0
    var vx: Double = 0
    var vy: Double = 0
    var spin: Double = 0
    var color: Color = .yellow
}

struct ConfettiBitView: View {
    let bit: ConfettiBit
    
    // Add animation states
    @State private var xOffset: CGFloat = 0
    @State private var yOffset: CGFloat = 0
    @State private var rotation: Double = 0
    
    var body: some View {
        Rectangle()
            .fill(bit.color)
            .frame(width: 12, height: 8)
            .rotationEffect(.degrees(rotation))
            .position(x: bit.x + xOffset, y: bit.y + yOffset)
            .onAppear {
                // Initial velocity
                withAnimation(.interpolatingSpring(stiffness: 40, damping: 8).speed(1)) {
                    xOffset = CGFloat(bit.vx)
                    yOffset = CGFloat(bit.vy)
                    rotation = bit.spin * 10
                }
                
                // Gravity effect
                withAnimation(
                    .easeIn(duration: 2.4)
                    .delay(0.1) // Slight delay for more natural movement
                ) {
                    yOffset += 400
                    rotation += bit.spin * 20 // Additional spin during fall
                }
            }
    }
}

struct ConfettiView_Previews: PreviewProvider {
    static var previews: some View {
        ConfettiView()
            .frame(height: 400)
    }
}
