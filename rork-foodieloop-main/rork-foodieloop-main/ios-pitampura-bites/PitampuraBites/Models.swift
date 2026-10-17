//
//  Models.swift
//  PitampuraBites
//
//  Core domain types. Kept free of UI so a real backend can replace
//  MockData later without touching views.
//

import Foundation
import UIKit

/// A food place (restaurant or street stall).
struct Shop: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let category: String
    let locality: String
    /// 1 = ₹, 2 = ₹₹, 3 = ₹₹₹
    let priceLevel: Int
    let rating: Double
    /// Bundled image asset name.
    let imageName: String
    let signatureDish: String
    let blurb: String
    let isOpenNow: Bool
    let tags: [String]

    var priceText: String {
        String(repeating: "₹", count: priceLevel)
    }

    /// e.g. "Momos · Pitampura"
    var subtitle: String {
        "\(category) · \(locality)"
    }
}

/// A friend in the user's circle.
struct Friend: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let avatarImageName: String
}

/// Who wrote a visit/review.
enum VisitAuthor: Hashable, Codable {
    case friend(Friend)
    /// The signed-in user's avatar lives in AppState, not on the visit.
    case user(displayName: String)

    var name: String {
        switch self {
        case .friend(let friend): return friend.name
        case .user(let displayName): return displayName
        }
    }

    /// Bundled avatar asset name; the user's avatar is uploaded data instead.
    var avatarImageName: String? {
        switch self {
        case .friend(let friend): return friend.avatarImageName
        case .user: return nil
        }
    }
}

/// One visit to a shop, optionally reviewed.
struct Visit: Identifiable, Hashable, Codable {
    let id: UUID
    let shopID: String
    let author: VisitAuthor
    /// 1...5
    let rating: Double
    let quote: String
    let tags: [String]
    let companions: [String]
    /// nil = not answered; true/false = would / would not return.
    let wantsToReturn: Bool?
    /// Optional down-scaled JPEG of the attached photo.
    let photoData: Data?
    let date: Date

    /// Decoded photo for display, or nil when absent/corrupt.
    var photo: UIImage? {
        photoData.flatMap(UIImage.init(data:))
    }
}

/// Food reaction used by the quick review flow. Maps to a 1-5 rating.
enum FoodReaction: String, CaseIterable, Identifiable {
    case obsessed = "😍"
    case fire = "🔥"
    case yummy = "😋"
    case decent = "🙂"
    case meh = "😕"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .obsessed: return "Obsessed"
        case .fire: return "Fire"
        case .yummy: return "Yummy"
        case .decent: return "Decent"
        case .meh: return "Meh"
        }
    }

    var rating: Double {
        switch self {
        case .obsessed, .fire: return 5
        case .yummy: return 4
        case .decent: return 3
        case .meh: return 2
        }
    }
}

/// Return intention answers for the quick review flow.
enum ReturnIntention: String, CaseIterable, Identifiable {
    case yes, maybe, no

    var id: String { rawValue }

    var label: String {
        switch self {
        case .yes: return "Going back"
        case .maybe: return "Maybe"
        case .no: return "One time only"
        }
    }

    var isPositive: Bool? {
        switch self {
        case .yes: return true
        case .maybe: return nil
        case .no: return false
        }
    }
}
