/**
 * NetworkService - AI-First Meal Suggestion with Database Fallback
 * 
 * ARCHITECTURE:
 * 1. Try AI-first Edge Function (suggest_meal_ai) with caching and timeout
 * 2. If AI fails/times out → Fall back to database-first function (suggest_meal)
 * 3. Handle all response types: AI-generated, cached, database fallback
 * 
 * RESPONSE DETECTION:
 * - cachedResult: true if meal came from cache
 * - backgroundGenerated: true if AI was slow and DB fallback used
 * - aiGenerated: true if meal was AI-generated (cached or fresh)
 * - fallbackUsed: true if database fallback was used
 */

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
    case aiGenerationFailed(String)
    case aiTimeout
    case aiInvalidResponse
    
    var errorDescription: String? {
        switch self {
        case .supabaseNotConfigured:
            return "Please check your internet connection and try again"
        case .edgeFunctionFailed(_):
            return "Unable to connect to our servers. Please try again in a moment"
        case .noMealFound:
            return "No meals match your preferences. Try adjusting your settings or try again"
        case .decodingError:
            return "Something went wrong while loading your meal. Please try again"
        case .noInternetConnection:
            return "No internet connection. Please check your network and try again"
        case .aiGenerationFailed(_):
            return "AI meal generation failed. Using fallback suggestions."
        case .aiTimeout:
            return "AI is taking longer than expected. Using fallback suggestions."
        case .aiInvalidResponse:
            return "AI response was invalid. Using fallback suggestions."
        }
    }
}

// ⚡ PERFORMANCE: Removed @MainActor to run network calls on background threads
final class NetworkService {
    // Helper to access @MainActor-isolated OfflineService
    private func getOfflineService() async -> OfflineService {
        await MainActor.run { OfflineService.shared }
    }
    
    private var useSupabase: Bool {
        SecretsConfig.shared.supabaseURL != nil && SecretsConfig.shared.supabaseAnonKey != nil
    }
    
    // Toggle this to true for development/testing when Supabase is having issues
    private let allowFallbackToStub = false

    func fetchMealSuggestion(preferences: UserPreferences, recentMealIds: [UUID] = []) async throws -> Meal {
        // ⚡ PERFORMANCE: Removed redundant connectivity check
        // URLSession handles connectivity internally and fails fast (< 10ms)
        // Pre-flight check to apple.com was adding 200-500ms latency
        
        if useSupabase {
            // Try AI-first approach with automatic fallback
            do {
                if let meal = try await invokeSuggestMealAI(preferences: preferences, recentMealIds: recentMealIds) {
                    // Cache the meal for offline use
                    let offlineService = await getOfflineService()
                    await offlineService.cacheMeal(meal)
                    return meal
                } else {
                    throw NetworkError.noMealFound
                }
            } catch is NetworkError {
                // Fallback to original database-first function
                do {
                    if let meal = try await invokeSuggestMeal(preferences: preferences, recentMealIds: recentMealIds) {
                        // Cache the meal for offline use
                        let offlineService = await getOfflineService()
                        await offlineService.cacheMeal(meal)
                        return meal
                    } else {
                        throw NetworkError.noMealFound
                    }
                } catch {
                    // Try offline fallback as last resort
                    let offlineService = await getOfflineService()
                    if let offlineMeal = await offlineService.getRandomOfflineMeal(matching: preferences) {
                        print("🌐 [NetworkService] Using offline fallback after database error: \(offlineMeal.title)")
                        return offlineMeal
                    }
                    throw NetworkError.noMealFound
                }
            } catch {
                // Fallback to original database-first function
                do {
                    if let meal = try await invokeSuggestMeal(preferences: preferences, recentMealIds: recentMealIds) {
                        // Cache the meal for offline use
                        let offlineService = await getOfflineService()
                        await offlineService.cacheMeal(meal)
                        return meal
                    } else {
                        throw NetworkError.noMealFound
                    }
                } catch {
                    // Try offline fallback as last resort
                    let offlineService = await getOfflineService()
                    if let offlineMeal = await offlineService.getRandomOfflineMeal(matching: preferences) {
                        print("🌐 [NetworkService] Using offline fallback after AI error: \(offlineMeal.title)")
                        return offlineMeal
                    }
                    throw NetworkError.edgeFunctionFailed(error.localizedDescription)
                }
            }
        } else {
            print("🍽️ [NetworkService] Supabase not configured")
            if allowFallbackToStub {
                print("🍽️ [NetworkService] Using fallback stub data for development")
                let stubMeal = try await createStubMeal()
                // Cache stub meal for offline use
                let offlineService = await getOfflineService()
                await offlineService.cacheMeal(stubMeal)
                return stubMeal
            } else {
                // Try offline fallback when Supabase is not configured
                let offlineService = await getOfflineService()
                if let offlineMeal = await offlineService.getRandomOfflineMeal(matching: preferences) {
                    print("🌐 [NetworkService] Using offline fallback when Supabase not configured: \(offlineMeal.title)")
                    return offlineMeal
                }
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
        let aiGenerated: Bool?
        let fallbackUsed: Bool?
        let cachedResult: Bool?
        let backgroundGenerated: Bool?
    }

    // MARK: - AI-First Edge Function
    private func invokeSuggestMealAI(preferences: UserPreferences, recentMealIds: [UUID] = []) async throws -> Meal? {
        guard let baseURL = SecretsConfig.shared.supabaseURL,
              let key = SecretsConfig.shared.supabaseAnonKey else { 
            print("🤖 [NetworkService] Missing Supabase credentials")
            throw NetworkError.supabaseNotConfigured
        }

        let url = baseURL.appendingPathComponent("functions/v1/suggest_meal_ai")
        
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
            recentMealIds: recentMealIds.map { $0.uuidString },
            ingredientHint: nil
        )

        let encoder = JSONEncoder()
        let body = try encoder.encode(req)
        request.httpBody = body

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { 
            throw NetworkError.edgeFunctionFailed("Invalid HTTP response")
        }
        
        guard (200..<300).contains(http.statusCode) else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "HTTP \(http.statusCode)"
            throw NetworkError.edgeFunctionFailed(errorMessage)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        
        do {
            let res = try decoder.decode(SuggestResponse.self, from: data)
            
            if res.status == "ok", let meal = res.meal {
                // Log meal source for debugging (cache, AI, or database fallback)
                let cachedResult = res.cachedResult ?? false
                let backgroundGenerated = res.backgroundGenerated ?? false
                let source = cachedResult ? "Cache" : (backgroundGenerated ? "Database Fallback" : "AI Generation")
                print("🤖 [NetworkService] Meal: \(meal.title) (Source: \(source))")
                return meal
            } else {
                throw NetworkError.noMealFound
            }
        } catch {
            // Re-throw NetworkError as-is, otherwise wrap in aiInvalidResponse
            if error is NetworkError {
                throw error
            } else {
                throw NetworkError.aiInvalidResponse
            }
        }
    }

    // MARK: - Database-First Edge Function (Fallback)
    private func invokeSuggestMeal(preferences: UserPreferences, recentMealIds: [UUID] = []) async throws -> Meal? {
        guard let baseURL = SecretsConfig.shared.supabaseURL,
              let key = SecretsConfig.shared.supabaseAnonKey else { 
            print("🔄 [NetworkService] Missing Supabase credentials")
            throw NetworkError.supabaseNotConfigured
        }

        let url = baseURL.appendingPathComponent("functions/v1/suggest_meal")
        
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
            recentMealIds: recentMealIds.map { $0.uuidString },
            ingredientHint: nil
        )

        let encoder = JSONEncoder()
        let body = try encoder.encode(req)
        request.httpBody = body
        
        print("🔄 [NetworkService] Recent meal IDs being sent: \(recentMealIds)")
        print("🔄 [NetworkService] Request payload: \(String(data: body, encoding: .utf8) ?? "Unable to decode")")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { 
            print("🔄 [NetworkService] Invalid HTTP response")
            throw NetworkError.edgeFunctionFailed("Invalid HTTP response")
        }
        
        print("🔄 [NetworkService] HTTP Status Code: \(http.statusCode)")
        print("🔄 [NetworkService] Response data: \(String(data: data, encoding: .utf8) ?? "Unable to decode")")
        
        guard (200..<300).contains(http.statusCode) else {
            print("🔄 [NetworkService] HTTP error: \(http.statusCode)")
            let errorMessage = String(data: data, encoding: .utf8) ?? "HTTP \(http.statusCode)"
            throw NetworkError.edgeFunctionFailed(errorMessage)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        
        do {
            let res = try decoder.decode(SuggestResponse.self, from: data)
            
            if res.status == "ok", let meal = res.meal {
                print("🔄 [NetworkService] Successfully decoded fallback meal: \(meal.title)")
                print("🔄 [NetworkService] Meal ingredients count: \(meal.ingredients.count)")
                print("🔄 [NetworkService] First ingredient: \(meal.ingredients.first?.name ?? "none")")
                return meal
            } else {
                print("🔄 [NetworkService] Database Edge Function returned no_match or no meal. Status: \(res.status), Reason: \(res.reason ?? "None")")
                throw NetworkError.noMealFound
            }
        } catch {
            print("🔄 [NetworkService] Failed to decode fallback response: \(error)")
            if let decodingError = error as? DecodingError {
                print("🔄 [NetworkService] Decoding error details: \(decodingError)")
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
