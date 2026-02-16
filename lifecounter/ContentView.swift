
import SwiftUI

struct GameEvent: Identifiable {
    let id = UUID()
    let description: String
}

struct ContentView: View {
    @State private var playerNames: [String] = ["Player 1", "Player 2", "Player 3", "Player 4"]
    @State private var playerLives: [Int] = [20, 20, 20, 20]
    @State private var customAmounts: [Int] = [5, 5, 5, 5]
    @State private var history: [GameEvent] = []
    @State private var gameStarted = false
    @State private var gameOver = false
    @State private var showHistory = false
    @State private var editingNameIndex: Int? = nil
    @State private var editingNameText: String = ""

    var playerCount: Int { playerNames.count }

    var alivePlayers: [Int] {
        (0..<playerCount).filter { playerLives[$0] > 0 }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if playerCount < 8 {
                    Button("Add Player") {
                        let newIndex = playerCount + 1
                        playerNames.append("Player \(newIndex)")
                        playerLives.append(20)
                        customAmounts.append(5)
                    }
                    .disabled(gameStarted)
                    .padding(.top, 8)
                    .padding(.bottom, 4)
                }

                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(0..<playerCount, id: \.self) { i in
                            PlayerView(
                                name: playerNames[i],
                                life: $playerLives[i],
                                customAmount: $customAmounts[i],
                                onNameTap: {
                                    editingNameText = playerNames[i]
                                    editingNameIndex = i
                                },
                                onLifeChange: { change, label in
                                    gameStarted = true
                                    history.append(GameEvent(
                                        description: "\(playerNames[i]) \(change > 0 ? "gained" : "lost") \(abs(change)) life. (\(label))"
                                    ))
                                    checkGameOver()
                                }
                            )
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical, 8)
                }

                ForEach(0..<playerCount, id: \.self) { i in
                    if playerLives[i] <= 0 {
                        Text("\(playerNames[i]) LOSES!")
                            .font(.headline)
                            .foregroundColor(.red)
                    }
                }

                if gameOver {
                    VStack(spacing: 8) {
                        if let winner = alivePlayers.first {
                            Text("\(playerNames[winner]) WINS! Game Over!")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                        Button("OK") {
                            resetGame()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                }
            }
            .navigationTitle("Life Counter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        resetGame()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("History") {
                        showHistory = true
                    }
                }
            }
            .sheet(isPresented: $showHistory) {
                HistoryView(history: history)
            }
            .alert("Rename Player", isPresented: Binding(
                get: { editingNameIndex != nil },
                set: { if !$0 { editingNameIndex = nil } }
            )) {
                TextField("Name", text: $editingNameText)
                Button("OK") {
                    if let i = editingNameIndex {
                        playerNames[i] = editingNameText
                    }
                    editingNameIndex = nil
                }
                Button("Cancel", role: .cancel) {
                    editingNameIndex = nil
                }
            }
        }
    }

    private func checkGameOver() {
        if alivePlayers.count == 1 && playerCount > 1 {
            gameOver = true
        }
    }

    private func resetGame() {
        playerNames = ["Player 1", "Player 2", "Player 3", "Player 4"]
        playerLives = [20, 20, 20, 20]
        customAmounts = [5, 5, 5, 5]
        history = []
        gameStarted = false
        gameOver = false
    }
}

struct PlayerView: View {
    let name: String
    @Binding var life: Int
    @Binding var customAmount: Int
    let onNameTap: () -> Void
    let onLifeChange: (Int, String) -> Void

    var body: some View {
        VStack(spacing: 8) {
            Text(name)
                .font(.headline)
                .onTapGesture { onNameTap() }

            Text("\(life)")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(life <= 0 ? .red : .primary)
                .minimumScaleFactor(0.5)
                .lineLimit(1)

            HStack(spacing: 12) {
                Button("-1") {
                    life -= 1
                    onLifeChange(-1, "-1")
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)

                Button("+1") {
                    life += 1
                    onLifeChange(1, "+1")
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }

            HStack(spacing: 8) {
                Button("-\(customAmount)") {
                    life -= customAmount
                    onLifeChange(-customAmount, "-\(customAmount)")
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)

                TextField("Amt", value: $customAmount, format: .number)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 60)
                    .multilineTextAlignment(.center)

                Button("+\(customAmount)") {
                    life += customAmount
                    onLifeChange(customAmount, "+\(customAmount)")
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(life <= 0 ? Color.red.opacity(0.1) : Color.gray.opacity(0.1))
        )
    }
}

struct HistoryView: View {
    let history: [GameEvent]
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            List {
                if history.isEmpty {
                    Text("No events yet.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(history) { event in
                        Text(event.description)
                    }
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
