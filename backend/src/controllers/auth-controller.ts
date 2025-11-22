import type { Request, Response, NextFunction } from "express";
import jwt, { type JwtPayload } from 'jsonwebtoken';
import bcrypt from 'bcryptjs';

import User from "../models/user.js";
import CustomError from "../types/error-type.js";

const jwtSign = (userId: string, nickname: string, avatarPath?: string) => {
    return jwt.sign(
        {
            userId: userId,
            nickname: nickname,
            avatarPath: avatarPath,
        },
        process.env.JWT_SECRET as string,
        { expiresIn: '1h' }
    );
}

export const signup = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    const nickname = req.body.nickname;
    const email = req.body.email;
    const password = req.body.password;

    try {
        const hashedPassword = await bcrypt.hash(password, 12);
        const user = new User({
            nickname: nickname,
            email: email,
            password: hashedPassword
        });
        await user.save();
        const token = jwtSign(user._id.toString(), nickname);
        res.status(201).json({
            message: 'Signed up.',
            jwt: token
        });
    } catch (error: any) {
        console.log(error);
        if (error.code === 11000) {
            const field = Object.keys(error.keyValue)[0];
            const errorMessage = field === 'email' ? 'E-Mail already registered.' : 'Nickname already taken.';
            const customError = new CustomError(errorMessage, 401);
            customError.status = 401;
            return next(customError);
        }
        next(error);
    }
};

export const login = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    const { email, password } = req.body;
    try {
        const user = await User.findOne({ email: email });
        if (!user) {
            const error = new CustomError('E-Mail not registered yet.', 401);
            error.status = 401;
            throw error;
        }
        const isEqual = await bcrypt.compare(password, user.password);
        if (!isEqual) {
            const error = new CustomError('Password is incorrect.', 401);
            error.status = 401;
            throw error;
        }
        const userId = user._id.toString();
        const token = jwtSign(userId, user.nickname, user.avatar);
        res.status(200).json({
            message: 'Logged in.',
            jwt: token
        });
    } catch (error) {
        next(error);
    }
};

interface UserPayload extends JwtPayload {
  userId: string;
}

export const isAuth = (req: Request, res: Response, next: NextFunction) => {
  const token = req.headers.authorization?.split(" ")[1];
  if (!token) {
    const error = new CustomError("No token provided.", 401);
    next(error);
  }
  try {
    const decodedToken = jwt.verify(
      token!,
      process.env.JWT_SECRET!
    ) as UserPayload;
    req.userId = decodedToken.userId;
  } catch (e) {
    const error = new CustomError("Authentication failed.", 401);
    next(error);
  }
  next();
};