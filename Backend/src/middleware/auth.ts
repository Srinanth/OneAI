import { Request, Response, NextFunction } from 'express';
import { supabase } from '../services/supabase.js';

export interface AuthenticatedRequest extends Request {
  user?: {
    id: string;
    email?: string;
  };
}

export const requireAuth = async (req: AuthenticatedRequest, res: Response, next: NextFunction) => {
  const authHeader = req.headers.authorization;

  if (!authHeader) {
    return res.status(401).json({ error: 'Missing Authorization Header' });
  }

  const token = authHeader.split(' ')[1]; 

  const { data: { user }, error } = await supabase.auth.getUser(token);

  if (error || !user) {
    return res.status(403).json({ error: 'Invalid or Expired Token' });
  }

  req.user = { id: user.id, email: user.email };
  
  next();
};