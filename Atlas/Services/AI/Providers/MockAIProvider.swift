import Foundation

public class MockAIProvider: AIProvider {
    public init() {}
    
    public func generateText(prompt: String) async throws -> String {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Route to the appropriate mock response based on prompt content
        let lowered = prompt.lowercased()
        
        if lowered.contains("recovery recommendations") {
            return mockRecoveryRecommendations
        }
        
        if lowered.contains("optimize training") {
            return mockWorkoutRecommendations
        }
        
        if lowered.contains("nutrition recommendations") {
            return mockNutritionRecommendations
        }
        
        if lowered.contains("actionable insights") {
            return mockInsightsResponse
        }
        
        if lowered.contains("weekly") && lowered.contains("report") {
            return mockWeeklyReport
        }
        
        if lowered.contains("recipe") {
            return mockRecipeSuggestions
        }
        
        if lowered.contains("meal plan") {
            return mockMealPlan
        }
        
        return "[]"
    }
    
    public func analyzeImage(imageData: Data, prompt: String) async throws -> String {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 2_000_000_000)
        return mockMealRecognition
    }
    
    // MARK: - Mock Responses
    
    private var mockInsightsResponse: String {
        """
        [
            {
                "title": "Protein Goal",
                "message": "You only need 25g more protein to hit your daily target. A scoop of whey or some greek yogurt would be perfect.",
                "category": "Nutrition"
            },
            {
                "title": "Great Recovery",
                "message": "Your sleep score was 92 last night. You are primed for a heavy lifting session today.",
                "category": "Recovery"
            },
            {
                "title": "Hydration Alert",
                "message": "You've only logged 1L of water today. Drink up to improve performance and recovery.",
                "category": "General"
            }
        ]
        """
    }
    
    private var mockMealRecognition: String {
        """
        [
            {
                "name": "Grilled Chicken Breast",
                "calories": 284,
                "protein": 53.4,
                "carbs": 0,
                "fat": 6.2,
                "confidence": 0.98
            },
            {
                "name": "White Rice",
                "calories": 205,
                "protein": 4.3,
                "carbs": 44.5,
                "fat": 0.4,
                "confidence": 0.95
            },
            {
                "name": "Steamed Broccoli",
                "calories": 55,
                "protein": 3.7,
                "carbs": 11.2,
                "fat": 0.6,
                "fiber": 5.1,
                "confidence": 0.99
            }
        ]
        """
    }
    
    private var mockWorkoutRecommendations: String {
        """
        [
            {
                "suggestion_type": "increase_weight",
                "exercise_name": "Bench Press",
                "message": "You've hit 80kg x 8 consistently for 2 weeks. Try 82.5kg x 6 next session.",
                "reasoning": "Your rep consistency shows you've adapted to the current load.",
                "confidence": 0.88
            },
            {
                "suggestion_type": "rest_day",
                "exercise_name": null,
                "message": "You've trained 5 of the last 6 days. Schedule a rest day to optimize recovery.",
                "reasoning": "High training frequency without adequate recovery can lead to overtraining.",
                "confidence": 0.92
            },
            {
                "suggestion_type": "swap_exercise",
                "exercise_name": "Barbell Row",
                "message": "Consider switching to Chest-Supported Rows to reduce lower back fatigue from your deadlift days.",
                "reasoning": "Your training log shows deadlifts and rows on consecutive days, stacking spinal load.",
                "confidence": 0.78
            }
        ]
        """
    }
    
    private var mockNutritionRecommendations: String {
        """
        [
            {
                "suggestion_type": "protein_intake",
                "message": "Your average protein intake is 130g but your target is 160g. Add a high-protein snack like cottage cheese or jerky.",
                "details": "Greek yogurt (170g) with a scoop of protein powder gives you 40g protein for under 250 calories."
            },
            {
                "suggestion_type": "meal_timing",
                "message": "You're eating 60% of your calories after 6pm. Distribute meals more evenly for better energy throughout the day.",
                "details": "Try adding a proper lunch with at least 500 calories."
            },
            {
                "suggestion_type": "hydration",
                "message": "Your water intake averaged 1.5L over the past week. Aim for at least 2.5-3L, especially on training days.",
                "details": null
            }
        ]
        """
    }
    
    private var mockRecoveryRecommendations: String {
        """
        [
            {
                "recommendation_type": "heavy_workout",
                "message": "Your recovery score is 84 and HRV is above baseline. It's a great day for a challenging workout.",
                "reasoning": "High HRV and good sleep quality indicate strong parasympathetic recovery."
            },
            {
                "recommendation_type": "mobility",
                "message": "Add 10 minutes of hip and shoulder mobility before your workout.",
                "reasoning": "Your last 3 sessions were upper-body heavy. Mobility work will maintain range of motion."
            }
        ]
        """
    }
    
    private var mockWeeklyReport: String {
        """
        {
            "workout_consistency": 80.0,
            "nutrition_consistency": 65.0,
            "average_sleep_score": 78.0,
            "weight_trend": "Down 0.3kg",
            "macro_adherence": 72.0,
            "best_workout": "Tuesday — Upper Body (52 min, 6 exercises)",
            "suggested_focus": "Prioritize hitting your protein target daily. You were under 140g on 4 out of 7 days. Pre-make protein-rich snacks on Sunday.",
            "summary_text": "Solid training week with 4 workouts completed. Nutrition needs attention — protein was consistently below target. Sleep quality was strong with an average score of 78.",
            "highlights": [
                "Hit a Bench Press PR: 85kg x 5",
                "Maintained a 12-day workout streak",
                "Protein intake needs improvement — missed target 4/7 days"
            ]
        }
        """
    }
    
    private var mockRecipeSuggestions: String {
        """
        [
            {
                "name": "High-Protein Chicken Stir-Fry",
                "ingredients": [
                    {"name": "Chicken Breast", "quantity": "200g"},
                    {"name": "Brown Rice", "quantity": "150g cooked"},
                    {"name": "Broccoli", "quantity": "100g"},
                    {"name": "Soy Sauce", "quantity": "1 tbsp"},
                    {"name": "Sesame Oil", "quantity": "1 tsp"}
                ],
                "instructions": [
                    "Cut chicken into strips and season with soy sauce.",
                    "Heat sesame oil in a wok over high heat.",
                    "Stir-fry chicken for 5-6 minutes until golden.",
                    "Add broccoli and cook for 3 minutes.",
                    "Serve over brown rice."
                ],
                "estimated_calories": 480,
                "estimated_protein": 48,
                "estimated_carbs": 42,
                "estimated_fat": 10,
                "servings": 1
            },
            {
                "name": "Mediterranean Egg Bowl",
                "ingredients": [
                    {"name": "Eggs", "quantity": "3 large"},
                    {"name": "Spinach", "quantity": "50g"},
                    {"name": "Feta Cheese", "quantity": "30g"},
                    {"name": "Cherry Tomatoes", "quantity": "6"},
                    {"name": "Olive Oil", "quantity": "1 tsp"}
                ],
                "instructions": [
                    "Sauté spinach in olive oil until wilted.",
                    "Scramble eggs and add to the pan.",
                    "Top with halved cherry tomatoes and crumbled feta.",
                    "Season with salt, pepper, and oregano."
                ],
                "estimated_calories": 380,
                "estimated_protein": 28,
                "estimated_carbs": 8,
                "estimated_fat": 26,
                "servings": 1
            }
        ]
        """
    }
    
    private var mockMealPlan: String {
        """
        [
            {
                "day_label": "Day 1",
                "breakfast": {
                    "name": "Greek Yogurt Parfait",
                    "description": "Greek yogurt with mixed berries, granola, and a drizzle of honey.",
                    "estimated_calories": 420,
                    "estimated_protein": 30,
                    "estimated_carbs": 52,
                    "estimated_fat": 10
                },
                "lunch": {
                    "name": "Grilled Chicken Caesar Wrap",
                    "description": "Whole wheat wrap with grilled chicken, romaine, parmesan, and light Caesar dressing.",
                    "estimated_calories": 550,
                    "estimated_protein": 42,
                    "estimated_carbs": 45,
                    "estimated_fat": 18
                },
                "dinner": {
                    "name": "Salmon with Sweet Potato",
                    "description": "Baked salmon fillet with roasted sweet potato and steamed green beans.",
                    "estimated_calories": 620,
                    "estimated_protein": 45,
                    "estimated_carbs": 48,
                    "estimated_fat": 22
                },
                "snack": {
                    "name": "Protein Shake & Almonds",
                    "description": "Whey protein shake with a handful of almonds.",
                    "estimated_calories": 310,
                    "estimated_protein": 35,
                    "estimated_carbs": 12,
                    "estimated_fat": 14
                }
            }
        ]
        """
    }
}
