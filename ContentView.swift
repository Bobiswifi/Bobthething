import SwiftUI

struct ContentView: View {
    @State private var effect: BroccoliEffect? = nil
    @State private var confettiTrigger = false
    @State private var lastTap = Date.distantPast
    
    // MARK: - Constants
    private let effects: [BroccoliEffect] = [.wobble, .pulse, .spin, .float, .colorShift, .explode]
    private let debounceInterval: TimeInterval = 0.1
    private let hapticGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    // MARK: - Colors
    private let gradientTopColor = Color(red: 0.941, green: 0.973, blue: 0.957)
    private let gradientBottomColor = Color(red: 0.827, green: 0.918, blue: 0.890)
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [gradientTopColor, gradientBottomColor],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Fluffy Broccoli")
                    .font(.largeTitle.bold())
                    .foregroundStyle(LinearGradient(colors: [Color.green, Color.teal], startPoint: .topLeading, endPoint: .bottomTrailing))

                Text("Tap the broccoli to release stress — watch it do weird, silly things.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Spacer()

                ZStack {
                    BroccoliView(effect: effect)
                        .frame(width: 260, height: 340)
                        .accessibilityAddTraits(.isButton)
                        .onTapGesture {
                            let now = Date()
                            // gentle debounce
                            if now.timeIntervalSince(lastTap) < debounceInterval { return }
                            lastTap = now
                            // haptic feedback
                            hapticGenerator.impactOccurred()
                            triggerRandomEffect()
                        }

                    if confettiTrigger {
                        ConfettiView()
                            .allowsHitTesting(false)
                    }
                }

                Spacer()

                HStack(spacing: 16) {
                    Button(action: { triggerRandomEffect() }) {
                        Label("Do a thing", systemImage: "sparkles")
                    }
                    .buttonStyle(.borderedProminent)

                    Button(action: { effect = nil }) {
                        Label("Reset", systemImage: "arrow.clockwise")
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
        }
    }

    // MARK: - Effects
    func triggerRandomEffect() {
        // Choose a random effect but prefer a different one than current
        let availableEffects = effect.map { current in
            effects.filter { $0 != current }
        } ?? effects
        
        let choice = availableEffects.randomElement() ?? effects.randomElement()!
        effect = choice

        // For 'explode' or showy ones, emit confetti
        if choice == .explode || choice == .spin {
            confettiTrigger = true
            
            // Hide confetti after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation {
                    confettiTrigger = false
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
