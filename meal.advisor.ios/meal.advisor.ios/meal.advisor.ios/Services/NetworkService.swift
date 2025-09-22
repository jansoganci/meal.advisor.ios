//
//  NetworkService.swift
//  meal.advisor.ios
//
//  Thin wrapper placeholder for Supabase or API calls
//

import Foundation
import Network
#if canImport(Supabase)
import Supabase
#endif

enum NetworkError: LocalizedError {
    case supabaseNotConfigured
    case edgeFunctionFailed(String)
    case noMealFound
    case decodingError
    case noInternetConnection
    
    var errorDescription: String? {
        switch self {
        case .supabaseNotConfigured:
            return "Please check your internet connection and try again"
        case .edgeFunctionFailed(let reason):
            return "Unable to connect to our servers. Please try again in a moment"
        case .noMealFound:
            return "No meals match your preferences. Try adjusting your settings or try again"
        case .decodingError:
            return "Something went wrong while loading your meal. Please try again"
        case .noInternetConnection:
            return "No internet connection. Please check your network and try again"
        }
    }
}

final class NetworkService {
    private var useSupabase: Bool {
        SecretsConfig.shared.supabaseURL != nil && SecretsConfig.shared.supabaseAnonKey != nil
    }
    
    // Toggle this to true for development/testing when Supabase is having issues
    private let allowFallbackToStub = false
    
    private func checkNetworkConnectivity() async throws {
        // Simple connectivity check using a lightweight request
        guard let url = URL(string: "https://www.apple.com") else { return }
        
        do {
            let (_, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.noInternetConnection
            }
        } catch {
            throw NetworkError.noInternetConnection
        }
    }

    func fetchMealSuggestion(preferences: UserPreferences) async throws -> Meal {
        print("🍽️ [NetworkService] fetchMealSuggestion called")
        print("🍽️ [NetworkService] useSupabase: \(useSupabase)")
        
        // Check network connectivity first
        do {
            try await checkNetworkConnectivity()
        } catch {
            print("🍽️ [NetworkService] Network connectivity check failed")
            throw NetworkError.noInternetConnection
        }
        
        if useSupabase {
            print("🍽️ [NetworkService] Attempting to call Supabase Edge Function")
            // Prefer Edge Function (suggest_meal) which uses LLM reranking behind the scenes
            do {
                if let meal = try await invokeSuggestMeal(preferences: preferences) {
                    print("🍽️ [NetworkService] Successfully got meal from Supabase: \(meal.title)")
                    return meal
                } else {
                    print("🍽️ [NetworkService] Edge Function returned nil")
                    throw NetworkError.noMealFound
                }
            } catch let networkError as NetworkError {
                print("🍽️ [NetworkService] NetworkError: \(networkError.localizedDescription)")
                throw networkError
            } catch {
                print("🍽️ [NetworkService] Edge Function failed with error: \(error)")
                throw NetworkError.edgeFunctionFailed(error.localizedDescription)
            }
        } else {
            print("🍽️ [NetworkService] Supabase not configured")
            if allowFallbackToStub {
                print("🍽️ [NetworkService] Using fallback stub data for development")
                return try await createStubMeal()
            } else {
                throw NetworkError.supabaseNotConfigured
            }
        }
    }
    
    private func createStubMeal() async throws -> Meal {
        try await Task.sleep(nanoseconds: 300_000_000)
        let ingredients: [Ingredient] = [
            Ingredient(name: "Chicken breast", amount: "1", unit: "lb"),
            Ingredient(name: "Heavy cream", amount: "1", unit: "cup"),
            Ingredient(name: "Sun-dried tomatoes", amount: "1/2", unit: "cup"),
            Ingredient(name: "Spinach", amount: "2", unit: "cups")
        ]
        let instructions = [
            "Heat olive oil, season chicken, sear until golden.",
            "Add cream and sun-dried tomatoes; simmer.",
            "Stir in spinach; cook until wilted."
        ]
        let nutrition = NutritionInfo(calories: 520, protein: 42, carbs: 12, fat: 32)

        return Meal(
            id: UUID(),
            title: "Creamy Tuscan Chicken (Test Data)",
            description: "Rich, cozy weeknight dinner with sun-dried tomatoes and spinach.",
            prepTime: 25,
            difficulty: .easy,
            cuisine: .italian,
            dietTags: [.highProtein, .quickEasy],
            imageURL: nil,
            ingredients: ingredients,
            instructions: instructions,
            nutritionInfo: nutrition
        )
    }

    // MARK: - Edge Function Invocation (direct HTTP to avoid SDK coupling)
    private struct SuggestRequest: Codable {
        let locale: String?
        let timeOfDay: String?
        let preferences: Prefs
        let recentMealIds: [String]?
        let ingredientHint: String?

        struct Prefs: Codable {
            let dietaryRestrictions: [String]
            let cuisinePreferences: [String]
            let maxCookingTime: Int
            let difficultyPreference: String?
            let excludedIngredients: [String]?
            let servingSize: Int
        }
    }

    private struct SuggestResponse: Codable {
        let status: String
        let meal: Meal?
        let badges: [String]?
        let alternatives: [String]?
        let reason: String?
    }

    private func invokeSuggestMeal(preferences: UserPreferences) async throws -> Meal? {
        guard let baseURL = SecretsConfig.shared.supabaseURL,
              let key = SecretsConfig.shared.supabaseAnonKey else { 
            print("🍽️ [NetworkService] Missing Supabase credentials")
            throw NetworkError.supabaseNotConfigured
        }

        let url = baseURL.appendingPathComponent("functions/v1/suggest_meal")
        print("🍽️ [NetworkService] Calling Edge Function at: \(url)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(key, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")

        let req = SuggestRequest(
            locale: Locale.current.identifier,
            timeOfDay: timeOfDayString(),
            preferences: .init(
                dietaryRestrictions: Array(preferences.dietaryRestrictions.map { $0.rawValue }),
                cuisinePreferences: Array(preferences.cuisinePreferences.map { $0.rawValue }),
                maxCookingTime: preferences.maxCookingTime,
                difficultyPreference: preferences.difficultyPreference?.rawValue,
                excludedIngredients: Array(preferences.excludedIngredients),
                servingSize: preferences.servingSize
            ),
            recentMealIds: nil,
            ingredientHint: nil
        )

        let encoder = JSONEncoder()
        let body = try encoder.encode(req)
        request.httpBody = body
        
        print("🍽️ [NetworkService] Request payload: \(String(data: body, encoding: .utf8) ?? "Unable to decode")")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { 
            print("🍽️ [NetworkService] Invalid HTTP response")
            throw NetworkError.edgeFunctionFailed("Invalid HTTP response")
        }
        
        print("🍽️ [NetworkService] HTTP Status Code: \(http.statusCode)")
        print("🍽️ [NetworkService] Response data: \(String(data: data, encoding: .utf8) ?? "Unable to decode")")
        
        guard (200..<300).contains(http.statusCode) else {
            print("🍽️ [NetworkService] HTTP error: \(http.statusCode)")
            let errorMessage = String(data: data, encoding: .utf8) ?? "HTTP \(http.statusCode)"
            throw NetworkError.edgeFunctionFailed(errorMessage)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        
        do {
            let res = try decoder.decode(SuggestResponse.self, from: data)
            
            if res.status == "ok", let meal = res.meal {
                print("🍽️ [NetworkService] Successfully decoded meal: \(meal.title)")
                print("🍽️ [NetworkService] Meal ingredients count: \(meal.ingredients.count)")
                print("🍽️ [NetworkService] First ingredient: \(meal.ingredients.first?.name ?? "none")")
                return meal
            } else {
                print("🍽️ [NetworkService] Edge Function returned no_match or no meal. Status: \(res.status), Reason: \(res.reason ?? "None")")
                throw NetworkError.noMealFound
            }
        } catch {
            print("🍽️ [NetworkService] Failed to decode response: \(error)")
            if let decodingError = error as? DecodingError {
                print("🍽️ [NetworkService] Decoding error details: \(decodingError)")
            }
            throw NetworkError.decodingError
        }
    }

    private func timeOfDayString() -> String? {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5...10: return "breakfast"
        case 11...15: return "lunch"
        default: return "dinner"
        }
    }
}
