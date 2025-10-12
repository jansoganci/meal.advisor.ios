//
//  UnsplashService.swift
//  meal.advisor.ios
//
//  Unsplash API integration for fetching food photography dynamically
//
//  ARCHITECTURE:
//  - Fetch images on-demand when meals have no imageURL
//  - Custom query generation per meal (title + cuisine)
//  - Track downloads per Unsplash TOS
//  - Store attribution metadata for display
//

import Foundation

// MARK: - Models

struct UnsplashPhoto: Codable {
    let id: String
    let urls: UnsplashPhotoURLs
    let user: UnsplashUser
    let links: UnsplashPhotoLinks
    let description: String?
    let altDescription: String?
    
    enum CodingKeys: String, CodingKey {
        case id, urls, user, links, description
        case altDescription = "alt_description"
    }
}

struct UnsplashPhotoURLs: Codable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}

struct UnsplashUser: Codable {
    let name: String
    let username: String
    let links: UnsplashUserLinks
}

struct UnsplashUserLinks: Codable {
    let html: String
}

struct UnsplashPhotoLinks: Codable {
    let html: String
    let download: String
    let downloadLocation: String
    
    enum CodingKeys: String, CodingKey {
        case html, download
        case downloadLocation = "download_location"
    }
}

struct UnsplashSearchResponse: Codable {
    let total: Int
    let totalPages: Int
    let results: [UnsplashPhoto]
    
    enum CodingKeys: String, CodingKey {
        case total
        case totalPages = "total_pages"
        case results
    }
}

// MARK: - Attribution Model

struct UnsplashAttribution {
    let photographerName: String
    let photographerUsername: String
    let photographerURL: URL
    let unsplashURL: URL
    let photoID: String
}

// MARK: - Errors

enum UnsplashError: LocalizedError {
    case notConfigured
    case invalidResponse
    case noResults
    case rateLimitExceeded
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Unsplash API key not configured"
        case .invalidResponse:
            return "Invalid response from Unsplash API"
        case .noResults:
            return "No images found for this query"
        case .rateLimitExceeded:
            return "Unsplash API rate limit exceeded. Try again later."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Service

@MainActor
final class UnsplashService {
    static let shared = UnsplashService()
    
    private let baseURL = "https://api.unsplash.com"
    private var apiKey: String? {
        SecretsConfig.shared.unsplashAPIKey
    }
    
    // Cache attribution data in memory
    private var attributionCache: [String: UnsplashAttribution] = [:]
    
    private init() {}
    
    // MARK: - Public API
    
    /// Get a random food photo matching the meal
    func getRandomPhoto(for meal: Meal) async throws -> (url: URL, attribution: UnsplashAttribution) {
        guard let apiKey = apiKey else {
            print("🖼️ [Unsplash] API key not configured")
            throw UnsplashError.notConfigured
        }
        
        print("🖼️ [Unsplash] API key loaded: \(apiKey.prefix(10))...")
        
        // Generate custom query from meal
        let query = generateSearchQuery(for: meal)
        print("🖼️ [Unsplash] Search query: \(query)")
        
        var components = URLComponents(string: "\(baseURL)/photos/random")!
        components.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "orientation", value: "landscape"),
            URLQueryItem(name: "client_id", value: apiKey)
        ]
        
        guard let url = components.url else {
            print("🖼️ [Unsplash] Failed to construct URL")
            throw UnsplashError.invalidResponse
        }
        
        var request = URLRequest(url: url)
        request.setValue("v1", forHTTPHeaderField: "Accept-Version")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("🖼️ [Unsplash] Invalid HTTP response")
                throw UnsplashError.invalidResponse
            }
            
            print("🖼️ [Unsplash] HTTP Status: \(httpResponse.statusCode)")
            
            // Check rate limits
            if httpResponse.statusCode == 403 {
                print("🖼️ [Unsplash] Rate limit exceeded")
                throw UnsplashError.rateLimitExceeded
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                print("🖼️ [Unsplash] HTTP error: \(httpResponse.statusCode)")
                throw UnsplashError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            let photo = try decoder.decode(UnsplashPhoto.self, from: data)
            
            print("🖼️ [Unsplash] Found photo: \(photo.id) by \(photo.user.name)")
            
            // Track download (required by Unsplash TOS)
            await trackDownload(photo: photo)
            
            // Create attribution
            let attribution = UnsplashAttribution(
                photographerName: photo.user.name,
                photographerUsername: photo.user.username,
                photographerURL: getPhotographerURL(for: photo),
                unsplashURL: getUnsplashURL(),
                photoID: photo.id
            )
            
            // Cache attribution
            attributionCache[photo.urls.regular] = attribution
            
            // Use 'regular' size (good balance of quality and performance)
            guard let imageURL = URL(string: photo.urls.regular) else {
                print("🖼️ [Unsplash] Invalid image URL")
                throw UnsplashError.invalidResponse
            }
            
            print("🖼️ [Unsplash] ✅ Success: \(imageURL.absoluteString.prefix(60))...")
            
            return (imageURL, attribution)
            
        } catch let error as UnsplashError {
            throw error
        } catch {
            print("🖼️ [Unsplash] Network error: \(error)")
            throw UnsplashError.networkError(error)
        }
    }
    
    /// Get cached attribution for an image URL
    func getAttribution(for imageURL: String) -> UnsplashAttribution? {
        return attributionCache[imageURL]
    }
    
    /// Generate custom search query from meal properties
    func generateSearchQuery(for meal: Meal) -> String {
        let title = meal.title.lowercased()
        let cuisine = meal.cuisine.rawValue.lowercased()
        
        return "\(title) \(cuisine) food"
    }
    
    // MARK: - Private Helpers
    
    /// Track photo download (required by Unsplash API TOS)
    private func trackDownload(photo: UnsplashPhoto) async {
        guard let apiKey = apiKey,
              var components = URLComponents(string: photo.links.downloadLocation) else { return }
        
        components.queryItems = [URLQueryItem(name: "client_id", value: apiKey)]
        guard let url = components.url else { return }
        
        _ = try? await URLSession.shared.data(from: url)
    }
    
    /// Get photographer profile URL (with UTM params)
    private func getPhotographerURL(for photo: UnsplashPhoto) -> URL {
        var components = URLComponents(string: photo.user.links.html)!
        components.queryItems = [
            URLQueryItem(name: "utm_source", value: "meal_advisor"),
            URLQueryItem(name: "utm_medium", value: "referral")
        ]
        return components.url!
    }
    
    /// Get Unsplash homepage URL (for attribution)
    private func getUnsplashURL() -> URL {
        var components = URLComponents(string: "https://unsplash.com")!
        components.queryItems = [
            URLQueryItem(name: "utm_source", value: "meal_advisor"),
            URLQueryItem(name: "utm_medium", value: "referral")
        ]
        return components.url!
    }
    
    /// Format attribution string for display
    func getAttributionString(for attribution: UnsplashAttribution) -> String {
        return "Photo by \(attribution.photographerName) on Unsplash"
    }
}

