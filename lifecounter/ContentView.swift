//
//  ContentView.swift
//  lifecounter
//
//  Created by Keshav Kalia on 2/15/26.
//

import SwiftUI

struct ContentView: View {
    @State private var player1Life = 20
    @State private var player2Life = 20

    var losingMessage: String? {
        if player1Life <= 0 && player2Life <= 0 {
            return "Player 1 & Player 2 LOSE!"
        } else if player1Life <= 0 {
            return "Player 1 LOSES!"
        } else if player2Life <= 0 {
            return "Player 2 LOSES!"
        }
        return nil
    }

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                if geo.size.width > geo.size.height {
                    // Landscape — side by side
                    HStack(spacing: 0) {
                        PlayerView(name: "Player 1", life: $player1Life)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        Divider()
                        PlayerView(name: "Player 2", life: $player2Life)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                } else {
                    // Portrait — stacked
                    VStack(spacing: 0) {
                        PlayerView(name: "Player 1", life: $player1Life)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        Divider()
                        PlayerView(name: "Player 2", life: $player2Life)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }

                if let message = losingMessage {
                    Text(message)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.15))
                }
            }
        }
    }
}

struct PlayerView: View {
    let name: String
    @Binding var life: Int

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Text(name)
                .font(.title)
                .fontWeight(.semibold)

            Text("\(life)")
                .font(.system(size: 80, weight: .bold, design: .rounded))
                .foregroundColor(life <= 0 ? .red : .primary)
                .minimumScaleFactor(0.5)
                .lineLimit(1)

            HStack(spacing: 12) {
                LifeButton(label: "-5") { life -= 5 }
                LifeButton(label: "-")  { life -= 1 }
                LifeButton(label: "+")  { life += 1 }
                LifeButton(label: "+5") { life += 5 }
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding()
    }
}

struct LifeButton: View {
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, minHeight: 50)
        }
        .buttonStyle(.borderedProminent)
    }
}

#Preview {
    ContentView()
}
