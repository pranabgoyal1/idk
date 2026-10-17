//
//  MockData.swift
//  PitampuraBites
//
//  Realistic sample listings for Pitampura, Delhi. The single seam a real
//  backend will replace later.
//

import Foundation

enum MockData {
    // MARK: - Shops

    static let shops: [Shop] = [
        Shop(
            id: "chaat-corner",
            name: "Chaat Corner",
            category: "Street food",
            locality: "Pitampura",
            priceLevel: 1,
            rating: 4.6,
            imageName: "papdi_chaat_bowl",
            signatureDish: "Dahi bhalla & aloo tikki",
            blurb: "A 30-year-old cart near the metro station, famous for tangy dahi bhalla and crisp aloo tikki.",
            isOpenNow: true,
            tags: ["Cheap", "Quick", "Authentic"]
        ),
        Shop(
            id: "baba-momos",
            name: "Baba Momos",
            category: "Momos",
            locality: "Pitampura",
            priceLevel: 1,
            rating: 4.4,
            imageName: "momos_steamer_chutney",
            signatureDish: "Steamed veg & chicken momos",
            blurb: "Tiny stall, huge queues. The fiery red chutney is the whole point.",
            isOpenNow: true,
            tags: ["Cheap", "Spicy", "Quick"]
        ),
        Shop(
            id: "chole-bhature-wala",
            name: "Chole Bhature Wala",
            category: "North Indian",
            locality: "Pitampura",
            priceLevel: 1,
            rating: 4.7,
            imageName: "chole_bhature",
            signatureDish: "Chole bhature with pickled onions",
            blurb: "Fluffy bhature and slow-cooked chole, Sunday mornings are a ritual here.",
            isOpenNow: true,
            tags: ["Authentic", "Filling"]
        ),
        Shop(
            id: "cafe-brew-studio",
            name: "Cafe Brew Studio",
            category: "Cafe",
            locality: "Pitampura",
            priceLevel: 2,
            rating: 4.5,
            imageName: "latte_rosetta_art",
            signatureDish: "Single-origin pour-over",
            blurb: "Quiet corners, good playlists and genuinely serious coffee.",
            isOpenNow: true,
            tags: ["Cosy", "Laptop-friendly"]
        ),
        Shop(
            id: "gupta-sweets",
            name: "Gupta Sweets",
            category: "Sweet",
            locality: "Pitampura",
            priceLevel: 1,
            rating: 4.3,
            imageName: "jalebi_kulfi_falooda",
            signatureDish: "Hot jalebi with kulfi",
            blurb: "Jalebi fried to order in ghee. Pair it with a scoop of kulfi.",
            isOpenNow: false,
            tags: ["Sweet", "Family-style"]
        ),
        Shop(
            id: "roll-junction",
            name: "Roll Junction",
            category: "Street food",
            locality: "Rohini",
            priceLevel: 1,
            rating: 4.4,
            imageName: "grilled_kathi_roll_paneer",
            signatureDish: "Paneer kathi roll",
            blurb: "Char-grilled paneer rolls with mint chutney, open till late.",
            isOpenNow: true,
            tags: ["Late night", "Spicy"]
        )
    ]

    static func shop(id: String) -> Shop? {
        shops.first { $0.id == id }
    }

    /// Shown as the big swipeable cards on Home.
    static let trendingShops: [Shop] = [
        shop(id: "chaat-corner")!,
        shop(id: "baba-momos")!,
        shop(id: "chole-bhature-wala")!
    ]

    /// The quiet, loved places listed under Home's "Hidden gems".
    static let hiddenGems: [Shop] = [
        shop(id: "baba-momos")!,
        shop(id: "chole-bhature-wala")!,
        shop(id: "cafe-brew-studio")!
    ]

    // MARK: - Filters

    static let categories = ["All", "Street food", "Cafes", "North Indian", "Momos", "Sweet"]
    static let localities = ["Pitampura", "Rohini", "Shalimar Bagh"]

    // MARK: - Friends & their visits

    static let friends: [Friend] = [
        Friend(id: "riya", name: "Riya", avatarImageName: "woman_curly_hair_denim_jacket"),
        Friend(id: "kabir", name: "Kabir", avatarImageName: "indian_man_glasses_beard"),
        Friend(id: "simran", name: "Simran", avatarImageName: "indian_woman_mustard_top")
    ]

    static func friend(id: String) -> Friend? {
        friends.first { $0.id == id }
    }

    private static func minutesAgo(_ minutes: Int) -> Date {
        Date().addingTimeInterval(TimeInterval(-minutes * 60))
    }

    /// Seed feed for the Circle tab.
    static let seedVisits: [Visit] = [
        Visit(
            id: UUID(),
            shopID: "chole-bhature-wala",
            author: .friend(friend(id: "riya")!),
            rating: 4.7,
            quote: "Best chole bhature in Pitampura.",
            tags: ["Authentic", "Filling"],
            companions: ["Family"],
            wantsToReturn: true,
            photoData: nil,
            date: minutesAgo(120)
        ),
        Visit(
            id: UUID(),
            shopID: "baba-momos",
            author: .friend(friend(id: "kabir")!),
            rating: 4.5,
            quote: "The spicy chutney is unreal.",
            tags: ["Spicy"],
            companions: ["Friends"],
            wantsToReturn: true,
            photoData: nil,
            date: minutesAgo(60 * 26)
        ),
        Visit(
            id: UUID(),
            shopID: "cafe-brew-studio",
            author: .friend(friend(id: "simran")!),
            rating: 4.6,
            quote: "Great for working, calm all afternoon.",
            tags: ["Cosy", "Laptop-friendly"],
            companions: ["Solo"],
            wantsToReturn: nil,
            photoData: nil,
            date: minutesAgo(60 * 24 * 3)
        )
    ]

    // MARK: - Onboarding

    /// Usernames taken in the demo (used to show the mock availability check).
    static let takenUsernames: Set<String> = ["riya", "kabir", "simran", "aarav", "admin"]
}
