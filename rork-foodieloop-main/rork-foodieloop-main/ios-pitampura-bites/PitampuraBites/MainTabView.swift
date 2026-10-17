//
//  MainTabView.swift
//  PitampuraBites
//
//  Custom tab bar: four destinations with a raised lime Scan button in
//  the centre that opens the full-screen scanner.
//

import SwiftUI

enum MainTab: Hashable {
    case home, explore, circle, passport
}

struct MainTabView: View {
    @Environment(AppState.self) private var appState

    @State private var selectedTab: MainTab = .home
    @State private var showScan = false
    @State private var presentedShop: Shop?

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .home: HomeView(openShop: openShop)
                case .explore: ExploreView(openShop: openShop)
                case .circle: CircleView(openShop: openShop)
                case .passport: PassportView(openShop: openShop)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            tabBar
        }
        .background(Color.appBackground)
        .task { appState.location.requestCurrentLocality() }
        .fullScreenCover(isPresented: $showScan) {
            ScanView(openShop: openShop)
        }
        .fullScreenCover(item: $presentedShop) { shop in
            ShopDetailView(shop: shop)
        }
    }

    private func openShop(_ shop: Shop) {
        presentedShop = shop
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            tabItem(.home, icon: "house.fill", label: "Home")
            tabItem(.explore, icon: "magnifyingglass", label: "Explore")
            scanButton
            tabItem(.circle, icon: "person.2.fill", label: "Circle")
            tabItem(.passport, icon: "rosette", label: "Passport")
        }
        .padding(.horizontal, 14)
        .padding(.top, 14)
        .padding(.bottom, 10)
        .glassPanel(in: .rect(cornerRadius: 30))
        .padding(.horizontal, 12)
        .padding(.bottom, 4)
    }

    private func tabItem(_ tab: MainTab, icon: String, label: String) -> some View {
        Button {
            UISelectionFeedbackGenerator().selectionChanged()
            withAnimation(.spring(duration: 0.3)) { selectedTab = tab }
        } label: {
            VStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .symbolRenderingMode(.hierarchical)
                Text(label)
                    .font(.system(size: 11, weight: .medium))
            }
            .foregroundStyle(selectedTab == tab ? Color.lime : Color.appTextSecondary)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
        .accessibilityAddTraits(selectedTab == tab ? .isSelected : [])
    }

    private var scanButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            showScan = true
        } label: {
            Image(systemName: "qrcode.viewfinder")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.black)
                .frame(width: 54, height: 54)
                .background(Color.lime, in: .circle)
                .frame(maxWidth: .infinity)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Scan shop QR")
    }
}
