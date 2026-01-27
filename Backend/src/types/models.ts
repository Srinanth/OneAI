export interface ModelConfig {
    max: number;
    resetHours: number;
    displayName: string;
}

export const MODEL_LIMITS: Record<string, ModelConfig> = {
    'gemini-2.5-flash': { 
        max: 100000, 
        resetHours: 6, 
        displayName: 'Gemini 2.5 Flash' 
    },
    'deepseek/deepseek-chat': { 
        max: 5000, 
        resetHours: 12, 
        displayName: 'DeepSeek Chat' 
    },
    'default': { 
        max: 2000, 
        resetHours: 6, 
        displayName: 'Standard Model' 
    }
};

export const getModelLimit = (modelId: string): ModelConfig => {
    return MODEL_LIMITS[modelId] ?? MODEL_LIMITS['default']!;
};