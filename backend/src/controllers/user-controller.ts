import type { Request, Response, NextFunction } from 'express';
import User, { type IUser } from '../models/user.js';
import CustomError from '../types/error-type.js';

export const findByEmail = async (req: Request, res: Response, next: NextFunction) => {
    const email = req.query.email as string;
    try {
        if (!email) {
            const error = new CustomError('No user email provided.', 400);
            throw error;
        }
        const user = await User.findOne({ email: email });
        if (!user) {
            const error = new CustomError('User not found.', 404);
            throw error;
        }
        res.status(200).json({
            message: 'User found.',
            user: { userId: user._id, nickname: user.nickname }
        });
    } catch (error) {
        return next(error);
    }
};

export const findById = async (req: Request, res: Response, next: NextFunction) => {
    const userId = req.query.userId as string;
    try {
        if (!userId) {
            const error = new CustomError('No userId provided.', 400);
            throw error;
        }
        const user = await User.findById(userId);
        if (!user) {
            const error = new CustomError('User not found.', 404);
            throw error;
        }
        res.status(200).json({
            message: 'User found.',
            user: { email: user.email, nickname: user.nickname, avatar: user.avatar }
        });
    } catch (error) {
        return next(error);
    }
};

export const getContacts = async (req: Request, res: Response, next: NextFunction) => {
    try {
        const user = await User.findById(req.userId).populate('contacts');
        const contacts = (user!.contacts as unknown as IUser[]).map((c: IUser) => {
            return {
                userId: c._id,
                email: c.email,
                nickname: c.nickname,
                avatar: c.avatar
            };
        });
        res.status(200).json({
            message: 'Contacts found.',
            contacts: contacts
        });
    } catch (error) {
        return next(error);
    }

}