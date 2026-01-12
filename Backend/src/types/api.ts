
export interface ApiResponse<T> {           // Standard success response
  success: true;
  data: T;
  message?: string;
}


export interface ApiError {             // Standard error response
  success: false;
  error: {
    code: string;       // e.g: token limit exeeded
    message: string;
    details?: any;
  };
}