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
    'gemini-3-pro-preview': { 
        max: 1000000, 
        resetHours: 24, 
        displayName: 'Gemini 3 Pro' 
    },
    'openai/gpt-5-chat': { 
        max: 100000, 
        resetHours: 12, 
        displayName: 'GPT-5 Chat' 
    },
    'openai/gpt-5-pro': { 
        max: 1000, 
        resetHours: 24, 
        displayName: 'GPT-5 Pro' 
    },
    'deepseek/deepseek-chat': { 
        max: 100000, 
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