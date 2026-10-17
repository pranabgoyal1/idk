//
//  HomeView.swift
//  PitampuraBites
//
//  Minimal home: greeting header, one swipeable hero carousel of trending
//  places, a "Mutuals visited" rail, then quiet shop lists.
//

import SwiftUI

struct HomeView: View {
    @Environment(AppState.self) private var appState

    let openShop: (Shop) -> Void

    @State private var trendingPageID: String?
    @State private var showAreaPicker = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                header
                heroCarousel
                mutualsVisited
                hiddenGems
                freshOnTheMap
            }
            .padding(.bottom, 120)
        }
        .scrollIndicators(.hidden)
        .refreshable {
            try? await Task.sleep(for: .seconds(0.9))
            appState.refreshFeed()
        }
        .background(Color.appBackground)
        .sheet(isPresented: $showAreaPicker) {
            AreaPickerSheet(selected: appState.location.displayLocation) {
                appState.location.setManualLocality($0)
            }
            .presentationDetents([.medium])
            .presentationBackground(Color.appBackground)
        }
    }

    /// Location line — always tappable to re-open the area picker. The fill
    /// pin shows when a fix resolved (GPS or manual), the hollow pin while
    /// still locating.
    private var locationRow: some View {
        Button {
            showAreaPicker = true
        } label: {
            HStack(spacing: 5) {
                Image(systemName: appState.location.status == .locating ? "location" : "location.fill")
                    .font(.system(size: 12))
                Text(appState.location.displayLocation)
                    .font(.system(size: 14, weight: .medium))
                Image(systemName: "chevron.down")
                    .font(.system(size: 9, weight: .semibold))
            }
            .foregroundStyle(Color.appTextSecondary)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Choose your area")
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                locationRow

                Text("Hey \(appState.displayName.isEmpty ? "there" : appState.displayName)")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.white)
            }

            Spacer()

            AvatarView(imageData: appState.avatarImageData, size: 48, showsRing: true)
        }
        .padding(.horizontal, .screenMargin)
        .padding(.top, 12)
    }

    /// Large paging food cards with the next card peeking at the edge.
    private var heroCarousel: some View {
        VStack(spacing: 14) {
            ScrollView(.horizontal) {
                LazyHStack(spacing: 16) {
                    ForEach(MockData.trendingShops) { shop in
                        HeroCard(shop: shop)
                            .frame(width: heroCardWidth)
                            .onTapGesture { openShop(shop) }
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $trendingPageID)
            .contentMargins(.horizontal, .screenMargin, for: .scrollContent)
            .scrollIndicators(.hidden)
            .frame(height: 430)

            HStack(spacing: 6) {
                let currentIndex = MockData.trendingShops.firstIndex { $0.id == trendingPageID } ?? 0
                ForEach(0..<MockData.trendingShops.count, id: \.self) { index in
                    Capsule()
                        .fill(index == currentIndex ? Color.lime : Color.appSurfaceRaised)
                        .frame(width: index == currentIndex ? 18 : 6, height: 6)
                }
            }
            .animation(.spring(duration: 0.3), value: trendingPageID)
        }
    }

    private var hiddenGems: some View {
        VStack(alignment: .leading, spacing: 6) {
            SectionHeader(title: "Hidden gems")
                .padding(.bottom, 10)

            VStack(spacing: 4) {
                ForEach(MockData.hiddenGems) { shop in
                    Button {
                        openShop(shop)
                    } label: {
                        ShopRow(shop: shop)
                    }
                    .buttonStyle(.plain)
                    .padding(.vertical, 8)
                }
            }
        }
        .padding(.horizontal, .screenMargin)
    }

    /// Shops recently onboarded that trending hasn't covered yet.
    private var freshOnTheMap: some View {
        VStack(alignment: .leading, spacing: 6) {
            SectionHeader(title: "Fresh on the map")
                .padding(.bottom, 10)

            VStack(spacing: 4) {
                ForEach(MockData.shops.filter { !MockData.hiddenGems.contains($0) }) { shop in
                    Button {
                        openShop(shop)
                    } label: {
                        ShopRow(shop: shop)
                    }
                    .buttonStyle(.plain)
                    .padding(.vertical, 8)
                }
            }
        }
        .padding(.horizontal, .screenMargin)
    }

    /// Horizontal rail of friends' latest visits, tapping opens the shop.
    private var mutualsVisited: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Mutuals visited")
                .padding(.horizontal, .screenMargin)

            ScrollView(.horizontal) {
                LazyHStack(spacing: 14) {
                    ForEach(appState.recentFriendActivity(limit: 6)) { visit in
                        MutualCard(visit: visit) { shop in
                            openShop(shop)
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
            .contentMargins(.horizontal, .screenMargin, for: .scrollContent)
        }
    }

    private var heroCardWidth: CGFloat {
        UIScreen.main.bounds.width - 88
    }
}

/// A friend's latest visit, as a compact vertical card.
private struct MutualCard: View {
    let visit: Visit
    let openShop: (Shop) -> Void

    private var shop: Shop? { MockData.shop(id: visit.shopID) }

    var body: some View {
        Button {
            if let shop {
                openShop(shop)
            }
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    AuthorAvatarView(author: visit.author, size: 26)
                    Text(visit.author.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                    Spacer()
                    Text(Self.shortTimeAgo(visit.date))
                        .font(.system(size: 12))
                        .foregroundStyle(Color.appTextSecondary.opacity(0.7))
                }

                Image(shop?.imageName ?? "papdi_chaat_bowl")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 110)
                    .frame(maxWidth: .infinity)
                    .overlay(Color.black.opacity(0.08))
                    .clipShape(.rect(cornerRadius: 16))
                    .allowsHitTesting(false)

                VStack(alignment: .leading, spacing: 5) {
                    Text("at \(shop?.name ?? "a place")")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    RatingBadge(rating: visit.rating, fontSize: 13)
                }
            }
            .padding(14)
            .frame(width: 220)
            .background(Color.appSurface, in: .rect(cornerRadius: 20))
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(visit.author.name) rated \(shop?.name ?? "a place") \(visit.rating) out of 5")
    }

    private static func shortTimeAgo(_ date: Date) -> String {
        let seconds = Date().timeIntervalSince(date)
        switch seconds {
        case ..<60: return "now"
        case ..<3600: return "\(Int(seconds / 60))m ago"
        case ..<86400: return "\(Int(seconds / 3600))h ago"
        default: return "\(Int(seconds / 86400))d ago"
        }
    }
}

/// The large trending card: full-bleed photo, gradient, name + pink rating.
/// Color anchors the layout so the fill image can't inflate the frame.
private struct HeroCard: View {
    let shop: Shop

    var body: some View {
        Color.appSurface
            .overlay {
                Image(shop.imageName)
                    .resizable()
                    .scaledToFill()
                    .allowsHitTesting(false)
            }
            .overlay {
                LinearGradient(
                    colors: [.clear, .clear, .black.opacity(0.75)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .allowsHitTesting(false)
            }
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(shop.name)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(.white)
                    HStack(spacing: 12) {
                        RatingBadge(rating: shop.rating, fontSize: 15)
                        Text(shop.priceText)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.appTextSecondary)
                        if shop.isOpenNow { OpenNowChip() }
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .clipShape(.rect(cornerRadius: 24))
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(shop.name), rating \(shop.rating) out of 5")
    }
}
