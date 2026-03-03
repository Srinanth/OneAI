export interface ModelConfig {
    max: number;
    displayName: string;
}

export const MODEL_LIMITS: Record<string, ModelConfig> = {
    'gemini-2.5-flash': { 
        max: 1000000,
        displayName: 'Gemini 2.5 Flash' 
    },
    'gemini-3-pro-preview': { 
        max: 250000,
        displayName: 'Gemini 3 Pro' 
    },
    'gemini-2-flash': { 
        max: 1000000, 
        displayName: 'Gemini 2 Flash' 
    },

    'deepseek/deepseek-chat': { 
        max: 500000, 
        displayName: 'DeepSeek V3' 
    },
    'deepseek/deepseek-reasoner': { 
        max: 200000, 
        displayName: 'DeepSeek R1' 
    },

    'openai/gpt-4o': { 
        max: 100000, 
        displayName: 'GPT-4o' 
    },
    'openai/gpt-4o-mini': { 
        max: 500000, 
        displayName: 'GPT-4o Mini' 
    },

    'anthropic/claude-3-5-sonnet': { 
        max: 50000, 
        displayName: 'Claude 3.5 Sonnet' 
    },
    'anthropic/claude-3-5-haiku': { 
        max: 300000, 
        displayName: 'Claude 3.5 Haiku' 
    },

    'xai/grok-2': { 
        max: 100000, 
        displayName: 'Grok 2' 
    },
    'xai/grok-beta': { 
        max: 200000, 
        displayName: 'Grok Beta' 
    },

    'default': { 
        max: 50000, 
        displayName: 'Standard Model' 
    }
};

export const getModelLimit = (modelId: string): ModelConfig => {
    return MODEL_LIMITS[modelId] ?? MODEL_LIMITS['default']!;
};