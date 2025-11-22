import type { Request, Response, NextFunction } from 'express';
import type CustomError from '../types/error-type.js';

export default (error: CustomError | any, req: Request, res: Response, next: NextFunction) => {
    const statusCode = error.status || 500;
    const message = error.message || 'An error occured';
    res.status(statusCode).json({ message });
};
