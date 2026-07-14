import Foundation

/// Centralized prompt library for all Atlas Intelligence features.
/// All prompts are stored here — never hardcode prompts in Views or ViewModels.
public struct PromptBuilder {
    
    // MARK: - System Preamble
    
    private static let systemPreamble = """
    You are Atlas Intelligence, a proactive health and fitness coach embedded in a mobile app.
    You are NOT a chatbot. You provide specific, actionable, data-driven coaching.
    Never use generic motivational text. Be concise and direct.
    Always return ONLY valid JSON matching the specified schema — no markdown, no extra text.
    """
    
    // MARK: - Daily Insights
    
    public static func buildInsightPrompt(userMetrics: String) -> String {
        return """
        \(systemPreamble)
        
        Analyze the following user data for today:
        \(userMetrics)
        
        Generate exactly 3 actionable insights based on this data. Be highly specific to the numbers provided.
        
        Return ONLY a valid JSON array:
        [
            {
                "title": "Short title (3-5 words)",
                "message": "Actionable specific advice based on the data (1-2 sentences)",
                "category": "Nutrition" | "Workout" | "Recovery" | "General"
            }
        ]
        """
    }
    
    // MARK: - Meal Recognition
    
    public static func buildMealRecognitionPrompt() -> String {
        return """
        \(systemPreamble)
        
        Analyze the provided food image. Identify ALL individual food components visible.
        Estimate portion sizes and nutritional values for each component separately.
        
        Return ONLY a valid JSON array:
        [
            {
                "name": "Food name",
                "calories": 250,
                "protein": 10.5,
                "carbs": 20.0,
                "fat": 5.0,
                "fiber": 2.0,
                "sugar": 1.0,
                "confidence": 0.95
            }
        ]
        
        Rules:
        - Identify each food component separately (e.g. chicken, rice, broccoli, sauce)
        - Estimate realistic portion sizes
        - Confidence should reflect how certain you are (0.0 to 1.0)
        - Include fiber and sugar when estimable
        """
    }
    
    // MARK: - Workout Coach
    
    public static func buildWorkoutCoachPrompt(history: String) -> String {
        return """
        \(systemPreamble)
        
        Analyze the following workout history from the past 7-14 days:
        \(history)
        
        Provide 2-4 specific recommendations to optimize training. Consider:
        - Progressive overload opportunities
        - Overtraining signals (high volume, declining performance)
        - Muscle group balance
        - Recovery needs
        
        Return ONLY a valid JSON array:
        [
            {
                "suggestion_type": "increase_weight" | "increase_reps" | "deload" | "reduce_fatigue" | "swap_exercise" | "rest_day" | "add_exercise",
                "exercise_name": "Exercise name or null if general",
                "message": "Specific recommendation (1-2 sentences)",
                "reasoning": "Why this recommendation (1 sentence)",
                "confidence": 0.85
            }
        ]
        """
    }
    
    // MARK: - Nutrition Coach
    
    public static func buildNutritionCoachPrompt(nutrition: String, goals: String) -> String {
        return """
        \(systemPreamble)
        
        Analyze the following nutrition data from recent days:
        \(nutrition)
        
        User's goals and profile:
        \(goals)
        
        Provide 2-4 specific nutrition recommendations. Consider:
        - Calorie adherence to target
        - Macro balance (especially protein)
        - Meal timing patterns
        - Micronutrient gaps (based on food variety)
        - Hydration
        
        Return ONLY a valid JSON array:
        [
            {
                "suggestion_type": "meal_suggestion" | "protein_intake" | "hydration" | "substitution" | "meal_timing" | "calorie_adjustment",
                "message": "Specific recommendation (1-2 sentences)",
                "details": "Optional additional context or food suggestion"
            }
        ]
        """
    }
    
    // MARK: - Recovery Coach
    
    public static func buildRecoveryCoachPrompt(health: String) -> String {
        return """
        \(systemPreamble)
        
        Analyze the following recovery and health data:
        \(health)
        
        Provide 1-3 recovery recommendations. Consider:
        - Sleep quality and duration
        - HRV trends (higher is better, indicating parasympathetic readiness)
        - Resting heart rate (lower is better; elevated suggests fatigue)
        - Recent training volume and intensity
        - Recovery score
        
        Return ONLY a valid JSON array:
        [
            {
                "recommendation_type": "rest" | "light_workout" | "heavy_workout" | "mobility" | "sleep",
                "message": "Specific recommendation (1-2 sentences)",
                "reasoning": "Why this recommendation based on the data (1 sentence)"
            }
        ]
        """
    }
    
    // MARK: - Weekly Report
    
    public static func buildWeeklyReportPrompt(weekData: String) -> String {
        return """
        \(systemPreamble)
        
        Generate a weekly fitness report from the following 7-day data:
        \(weekData)
        
        Return ONLY a valid JSON object:
        {
            "workout_consistency": 85.0,
            "nutrition_consistency": 70.0,
            "average_sleep_score": 78.0,
            "weight_trend": "Down 0.3kg",
            "macro_adherence": 75.0,
            "best_workout": "Tuesday - Upper Body",
            "suggested_focus": "Specific focus for next week (1-2 sentences)",
            "summary_text": "Overall week summary (2-3 sentences)",
            "highlights": ["Achievement 1", "Achievement 2", "Area to improve"]
        }
        
        Rules:
        - Consistency/adherence values are percentages (0-100)
        - Weight trend should be relative to start of week
        - Be specific in summary and focus, not generic
        """
    }
    
    // MARK: - Recipe Builder
    
    public static func buildRecipePrompt(ingredients: String, goal: String, targetCalories: Int, targetProtein: Int) -> String {
        return """
        \(systemPreamble)
        
        Generate 2-3 recipe suggestions using these inputs:
        
        Available ingredients: \(ingredients)
        Goal: \(goal)
        Target calories per serving: ~\(targetCalories) kcal
        Target protein per serving: ~\(targetProtein)g
        
        Return ONLY a valid JSON array:
        [
            {
                "name": "Recipe name",
                "ingredients": [
                    {"name": "Ingredient", "quantity": "200g"}
                ],
                "instructions": ["Step 1", "Step 2", "Step 3"],
                "estimated_calories": 450,
                "estimated_protein": 35,
                "estimated_carbs": 40,
                "estimated_fat": 15,
                "servings": 2
            }
        ]
        
        Rules:
        - Use the provided ingredients as the base (can suggest a few additions)
        - Keep instructions concise and practical
        - Nutritional estimates should be realistic
        """
    }
    
    // MARK: - Meal Planner
    
    public static func buildMealPlanPrompt(days: Int, preferences: String, allergies: String, targets: String) -> String {
        return """
        \(systemPreamble)
        
        Generate a \(days)-day meal plan with these constraints:
        
        Dietary preferences: \(preferences)
        Allergies/restrictions: \(allergies)
        Daily targets: \(targets)
        
        Return ONLY a valid JSON array with one entry per day:
        [
            {
                "day_label": "Day 1",
                "breakfast": {
                    "name": "Meal name",
                    "description": "Brief description with key ingredients",
                    "estimated_calories": 400,
                    "estimated_protein": 30,
                    "estimated_carbs": 45,
                    "estimated_fat": 12
                },
                "lunch": { ... },
                "dinner": { ... },
                "snack": { ... }
            }
        ]
        
        Rules:
        - Respect ALL dietary preferences and allergies strictly
        - Daily totals should approximate the targets
        - Vary meals across days — no repetition
        - Include realistic, commonly available foods
        - Snack is optional but recommended
        """
    }
}
