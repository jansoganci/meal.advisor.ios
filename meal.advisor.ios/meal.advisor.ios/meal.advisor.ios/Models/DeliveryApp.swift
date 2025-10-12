//
//  DeliveryApp.swift
//  meal.advisor.ios
//
//  Delivery app options for meal ordering
//

import Foundation

enum DeliveryApp: String, CaseIterable, Identifiable {
    case uberEats = "UberEats"
    case doorDash = "DoorDash"
    case grubhub = "Grubhub"
    case yemeksepeti = "Yemeksepeti"
    case getirYemek = "Getir Yemek"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .uberEats:
            return "UberEats"
        case .doorDash:
            return "DoorDash"
        case .grubhub:
            return "Grubhub"
        case .yemeksepeti:
            return "Yemeksepeti"
        case .getirYemek:
            return "Getir Yemek"
        }
    }
    
    var iconName: String {
        switch self {
        case .uberEats:
            return "car.fill"
        case .doorDash:
            return "bicycle"
        case .grubhub:
            return "bag.fill"
        case .yemeksepeti:
            return "fork.knife"
        case .getirYemek:
            return "takeoutbag.and.cup.and.straw.fill"
        }
    }
    
    func searchURL(for mealTitle: String) -> URL? {
        guard let encoded = mealTitle.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        
        let urlString: String
        switch self {
        case .uberEats:
            urlString = "https://www.ubereats.com/search?query=\(encoded)"
        case .doorDash:
            urlString = "https://www.doordash.com/search/?query=\(encoded)"
        case .grubhub:
            urlString = "https://www.grubhub.com/search?searchTerm=\(encoded)"
        case .yemeksepeti:
            urlString = "https://www.yemeksepeti.com/search?query=\(encoded)"
        case .getirYemek:
            urlString = "https://www.getiryemek.com/search?query=\(encoded)"
        }
        
        return URL(string: urlString)
    }
}

