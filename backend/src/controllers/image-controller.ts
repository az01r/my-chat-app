import multer, { type FileFilterCallback } from 'multer';
import type { Request, Response, NextFunction } from 'express';
import path from 'path';
import fs from 'fs';
import User from '../models/user.js';
import CustomError from '../types/error-type.js';

const UPLOADS_DIR = path.join('images', 'avatars');

if (!fs.existsSync(UPLOADS_DIR)) {
    try {
        fs.mkdirSync(UPLOADS_DIR, { recursive: true });
    } catch (err) {
        console.error(`Error creating uploads directory '${UPLOADS_DIR}':`, err);
    }
}

const fileFilter = (req: Request, file: Express.Multer.File, cb: FileFilterCallback) => {
    const isMimeTypeValid =
        file.mimetype === 'image/png' ||
        file.mimetype === 'image/jpg' ||
        file.mimetype === 'image/jpeg';

    cb(null, isMimeTypeValid);
}

const avatarsFileStorage = multer.diskStorage({
    destination: (req: Request, file: Express.Multer.File, cb: (error: Error | null, destination: string) => void) => {
        cb(null, path.join('images', 'avatars'));
    },
    filename: (req: Request, file: Express.Multer.File, cb: (error: Error | null, filename: string) => void) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);

        cb(null, `${uniqueSuffix}-${file.originalname}`);
    }
});

export const uploadAvatar = multer({
    storage: avatarsFileStorage,
    limits: { fileSize: 1024 * 1024 * 5 },
    fileFilter: fileFilter
}).single('avatar');

export const updateUserAvatar = async (req: Request, res: Response, next: NextFunction) => {
    try {
        if (!req.file) {
            // res.status(400).json({ message: 'No file uploaded.' });
            const error = new CustomError('No file uploaded.', 400);
            throw error;
        }
        const user = await User.findById(req.userId);
        if (!user) {
            const error = new CustomError('User not found.', 404);
            throw error;
        }
        user.avatar = req.file!.path;
        await user.save();
        res.status(200).json({
            message: 'File uploaded successfully!',
            filePath: req.file!.path
        });
    } catch (error) {
        next(error);
    }
}


