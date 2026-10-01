package com.sverto.app.core.ai

enum class CategorySuggestionConsent { LOADING, DISABLED, ENABLED }

data class CategorySuggestionSettings(
    val consent: CategorySuggestionConsent = CategorySuggestionConsent.LOADING,
    val saving: Boolean = false,
    val errorMessage: String? = null,
)
