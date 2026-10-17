//
//  ScanView.swift
//  PitampuraBites
//
//  Full-screen scanner: lime corner brackets over a dimmed stall backdrop,
//  with a simulated match that opens the corresponding shop page. Includes a
//  flashlight toggle and minimal suggestions for onboarded shops near the
//  user. (The real camera QR pipeline replaces the simulation later.)
//

import SwiftUI

struct ScanView: View {
    let openShop: (Shop) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var phase: Phase = .scanning
    @State private var scanLineOffset: CGFloat = -120
    @State private var torchIsOn = false

    /// Shop the simulated scan currently matched (drives the bottom sheet).
    @State private var match: Shop?
    /// Shop opened as a full detail page from the match sheet or nearby list.
    @State private var detailShop: Shop?

    private enum Phase {
        case scanning, found
    }

    /// Successive demo scans cycle through onboarded shops nearby.
    private let matchCandidates = ["baba-momos", "chaat-corner", "cafe-brew-studio"]
        .compactMap { MockData.shop(id: $0) }
    @State private var matchIndex = 0

    /// Mock distances for the "onboarded near you" suggestions.
    private let nearbyShops: [(shopID: String, distance: String)] = [
        ("baba-momos", "350 m"),
        ("chaat-corner", "600 m"),
        ("cafe-brew-studio", "1.1 km")
    ]

    var body: some View {
        ZStack {
            backdrop
            overlayControls

            if phase == .found, let match {
                matchSheet(match)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .background(Color.appBackground)
        .animation(.spring(duration: 0.45), value: phase)
        .fullScreenCover(item: $detailShop) { shop in
            ShopDetailView(shop: shop)
        }
        .onAppear(perform: startScanTimer)
    }

    private func startScanTimer() {
        guard phase == .scanning else { return }
        withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
            scanLineOffset = 120
        }
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(7))
            guard phase == .scanning else { return }
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            match = matchCandidates[matchIndex % matchCandidates.count]
            matchIndex += 1
            withAnimation { phase = .found }
        }
    }

    // MARK: - Layers

    /// Color anchor keeps the ZStack at screen size; the fill image would
    /// otherwise inflate the layout width and break the match sheet.
    private var backdrop: some View {
        Color.black
            .ignoresSafeArea()
            .overlay {
                Image("street_food_stall_night")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
            .overlay {
                Color.black.opacity(torchIsOn ? 0.42 : 0.62)
                    .ignoresSafeArea()
            }
            .allowsHitTesting(false)
            .animation(.easeInOut(duration: 0.3), value: torchIsOn)
    }

    private var overlayControls: some View {
        VStack {
            topBar

            Spacer()

            scanFrame
                .frame(width: 250, height: 250)

            Text("Scan a shop's QR")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white.opacity(0.85))
                .padding(.top, 28)

            Spacer()

            if phase == .scanning {
                nearbySuggestions

                Text("Looking for the code…")
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.55))
                    .padding(.top, 18)
                    .padding(.bottom, 28)
            } else {
                Color.clear.frame(height: 60)
                    .padding(.bottom, 28)
            }
        }
    }

    private var topBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 38, height: 38)
                    .glassPanel(in: .circle)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close scanner")

            Spacer()

            Button {
                torchIsOn.toggle()
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            } label: {
                Image(systemName: torchIsOn ? "flashlight.on.fill" : "flashlight.off.fill")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(torchIsOn ? Color.lime : .white)
                    .frame(width: 38, height: 38)
                    .glassPanel(in: .circle)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(torchIsOn ? "Turn flashlight off" : "Turn flashlight on")
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
    }

    /// Minimal rows for onboarded shops close to the user.
    private var nearbySuggestions: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Onboarded near you")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.white.opacity(0.5))
                .textCase(.uppercase)
                .padding(.bottom, 6)

            ForEach(nearbyShops, id: \.shopID) { nearby in
                if let shop = MockData.shop(id: nearby.shopID) {
                    Button {
                        detailShop = shop
                    } label: {
                        HStack(spacing: 12) {
                            Image(shop.imageName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .clipShape(.rect(cornerRadius: 12))
                                .allowsHitTesting(false)

                            Text(shop.name)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.white)

                            Spacer()

                            Text(nearby.distance)
                                .font(.system(size: 13))
                                .foregroundStyle(.white.opacity(0.55))
                        }
                        .padding(.vertical, 7)
                        .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(shop.name), \(nearby.distance) away")
                }
            }
        }
        .padding(.horizontal, 28)
    }

    /// Lime corner brackets with an animated scan line inside.
    private var scanFrame: some View {
        ZStack {
            ScanBrackets()
                .stroke(Color.lime, style: .init(lineWidth: 5, lineCap: .round, lineJoin: .round))

            if phase == .scanning {
                Capsule()
                    .fill(Color.lime)
                    .frame(height: 3)
                    .frame(maxWidth: 200)
                    .offset(y: scanLineOffset)
                    .shadow(color: Color.lime.opacity(0.8), radius: 6)
                    .allowsHitTesting(false)
            }
        }
        .accessibilityHidden(true)
    }

    /// Bottom "match found" sheet with the shop preview.
    private func matchSheet(_ shop: Shop) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 14) {
                Image(shop.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 64, height: 64)
                    .clipShape(.rect(cornerRadius: 16))
                    .allowsHitTesting(false)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Match found")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.lime)
                        .textCase(.uppercase)
                    Text(shop.name)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                    HStack(spacing: 10) {
                        RatingBadge(rating: shop.rating, fontSize: 14)
                        Text(shop.subtitle)
                            .font(.system(size: 13))
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }
            }
            .padding(20)

            PrimaryButton(title: "Open shop") {
                detailShop = shop
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 8)

            Button {
                withAnimation { phase = .scanning }
                startScanTimer()
            } label: {
                Text("Scan again")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.appTextSecondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 24)
        }
        .background(Color.appSurface, in: .rect(cornerRadius: 28))
        .padding(.horizontal, 12)
        .padding(.bottom, 8)
    }
}

/// Draws only the four rounded corner brackets of the scan frame.
private struct ScanBrackets: Shape {
    func path(in rect: CGRect) -> Path {
        let radius: CGFloat = 26
        let length: CGFloat = 46
        var path = Path()

        path.move(to: CGPoint(x: rect.minX, y: rect.minY + length))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + radius, y: rect.minY),
            control: CGPoint(x: rect.minX, y: rect.minY)
        )
        path.addLine(to: CGPoint(x: rect.minX + length, y: rect.minY))

        path.move(to: CGPoint(x: rect.maxX - length, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY + radius),
            control: CGPoint(x: rect.maxX, y: rect.minY)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + length))

        path.move(to: CGPoint(x: rect.maxX, y: rect.maxY - length))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radius))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - radius, y: rect.maxY),
            control: CGPoint(x: rect.maxX, y: rect.maxY)
        )
        path.addLine(to: CGPoint(x: rect.maxX - length, y: rect.maxY))

        path.move(to: CGPoint(x: rect.minX + length, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + radius, y: rect.maxY))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: rect.maxY - radius),
            control: CGPoint(x: rect.minX, y: rect.maxY)
        )
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - length))

        return path
    }
}
