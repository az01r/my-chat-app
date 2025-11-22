import type { Request, Response, NextFunction } from 'express';
import Message from '../models/message.js';
import CustomError from '../types/error-type.js';

export const findByRecipiendAndSenderId = async (req: Request, res: Response, next: NextFunction) => {
    const theirId = req.query.theirId as string;
    try {
        if (!theirId) {
            const error = new CustomError('No user id provided.', 400);
            throw error;
        }
        const messages = await Message.find({
            $or: [
                { sender: theirId, recipient: req.userId },
                { sender: req.userId, recipient: theirId }
            ]
        }).sort({ createdAt: 1 });

        res.status(200).json({
            message: `${messages.length} messages found.`,
            messages: messages,
        });
    } catch (error) {
        return next(error);
    }
};