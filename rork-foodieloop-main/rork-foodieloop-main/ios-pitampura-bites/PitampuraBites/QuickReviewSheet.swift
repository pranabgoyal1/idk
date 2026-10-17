//
//  QuickReviewSheet.swift
//  PitampuraBites
//
//  Quick review: food reaction, tags, return intention, optional photo
//  and companions. Saves a Visit to AppState (all mock/local).
//

import SwiftUI
import PhotosUI

struct QuickReviewSheet: View {
    let shop: Shop
    /// Called after the visit is saved, e.g. to show a toast.
    let onSaved: () -> Void

    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @State private var reaction: FoodReaction?
    @State private var tags: Set<String> = []
    @State private var returnIntention: ReturnIntention?
    @State private var companions: Set<String> = []
    @State private var photoItem: PhotosPickerItem?
    @State private var photoImage: Image?
    /// Down-scaled JPEG persisted with the visit on submit.
    @State private var photoData: Data?

    private let availableTags = ["Cheap", "Authentic", "Spicy", "Quick", "Cosy", "Insta-worthy"]
    private let companionOptions = ["Solo", "Friends", "Family", "Date", "Coworkers"]

    private var canSubmit: Bool {
        reaction != nil && returnIntention != nil
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                header
                reactionRow
                tagRow
                returnRow
                photoRow
                companionsRow
                PrimaryButton(title: "Save review", isEnabled: canSubmit, action: submit)
                    .padding(.top, 6)
            }
            .padding(24)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .background(Color.appBackground)
    }

    // MARK: - Rows

    private var header: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Quick review")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.white)
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.appTextSecondary)
                        .frame(width: 34, height: 34)
                        .glassPanel(in: .circle)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Close")
            }

            HStack(spacing: 12) {
                Image(shop.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 44, height: 44)
                    .clipShape(.rect(cornerRadius: 12))
                Text("How was \(shop.name)?")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.appTextSecondary)
            }
        }
    }

    private var reactionRow: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("Food reaction")
            HStack(spacing: 12) {
                ForEach(FoodReaction.allCases) { option in
                    Button {
                        UISelectionFeedbackGenerator().selectionChanged()
                        withAnimation(.spring(duration: 0.25)) { reaction = option }
                    } label: {
                        VStack(spacing: 6) {
                            Text(option.rawValue)
                                .font(.system(size: 30))
                            Text(option.label)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(reaction == option ? .black : Color.appTextSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 76)
                        .background(
                            reaction == option ? Color.lime : Color.appSurface,
                            in: .rect(cornerRadius: 16)
                        )
                        .opacity(reaction == nil || reaction == option ? 1 : 0.5)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(option.label)
                }
            }
        }
    }

    private var tagRow: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("Tags")
            FlowChips(
                labels: availableTags,
                isSelected: { tags.contains($0) }
            ) { tag in
                if tags.contains(tag) {
                    tags.remove(tag)
                } else {
                    tags.insert(tag)
                }
            }
        }
    }

    private var returnRow: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("Would you go back?")
            HStack(spacing: 10) {
                ForEach(ReturnIntention.allCases) { option in
                    TagChip(label: option.label, isSelected: returnIntention == option) {
                        withAnimation(.spring(duration: 0.25)) { returnIntention = option }
                    }
                }
            }
        }
    }

    private var photoRow: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("Add a photo (optional)")

            HStack(spacing: 12) {
                PhotosPicker(selection: $photoItem, matching: .images) {
                    HStack(spacing: 8) {
                        Image(systemName: "camera")
                        Text(photoImage == nil ? "Add photo" : "Change")
                    }
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .frame(height: 48)
                    .glassPanel(in: .rect(cornerRadius: 16))
                }

                if let image = photoImage {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 48, height: 48)
                        .clipShape(.rect(cornerRadius: 12))

                    Button {
                        photoImage = nil
                        photoData = nil
                        photoItem = nil
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.appTextSecondary)
                            .frame(width: 48, height: 48)
                            .glassPanel(in: .rect(cornerRadius: 16))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Remove photo")
                }
            }
            .onChange(of: photoItem) { _, item in
                loadPhoto(from: item)
            }
        }
    }

    private var companionsRow: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("Who was there? (optional)")
            FlowChips(
                labels: companionOptions,
                isSelected: { companions.contains($0) }
            ) { companion in
                if companions.contains(companion) {
                    companions.remove(companion)
                } else {
                    companions.insert(companion)
                }
            }
        }
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(Color.appTextSecondary)
            .textCase(.uppercase)
    }

    private func loadPhoto(from item: PhotosPickerItem?) {
        guard let item else { return }
        Task { @MainActor in
            let data = try? await item.loadTransferable(type: Data.self)
            guard let data, let uiImage = UIImage(data: data) else { return }
            photoImage = Image(uiImage: uiImage)
            photoData = uiImage.downscaledJPEGData(maxDimension: 800)
        }
    }

    // MARK: - Submission

    private func submit() {
        guard let reaction, let returnIntention else { return }
        let visit = Visit(
            id: UUID(),
            shopID: shop.id,
            author: .user(
                displayName: appState.displayName.isEmpty ? "You" : appState.displayName
            ),
            rating: reaction.rating,
            quote: reaction.label,
            tags: Array(tags),
            companions: Array(companions),
            wantsToReturn: returnIntention.isPositive,
            photoData: photoData,
            date: Date()
        )
        appState.addVisit(visit)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        onSaved()
        dismiss()
    }
}

/// Wrapping row of TagChips.
private struct FlowChips: View {
    let labels: [String]
    let isSelected: (String) -> Bool
    let toggle: (String) -> Void

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 110), spacing: 10)], spacing: 10) {
            ForEach(labels, id: \.self) { label in
                TagChip(label: label, isSelected: isSelected(label)) {
                    toggle(label)
                }
            }
        }
    }
}
