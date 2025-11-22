import { Socket } from "socket.io";
import jwt from 'jsonwebtoken';

interface DecodedToken {
    userId: string;
}

export const authenticateSocket = (socket: Socket, next: (err?: Error) => void) => {
    const token = socket.handshake.auth?.token;

    if (!token) {
        console.error('Socket Authentication Error: No token provided.');
        return next(new Error('Authentication error: No token provided'));
    }

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET as string) as DecodedToken;
        if (!decoded.userId) {
            throw new Error('Invalid token payload.')
        }
        // Attach userId to the socket object for later use
        socket.userId = decoded.userId;
        next(); // Proceed to connection
    } catch (err) {
        console.error('Socket Authentication Error:', err);
        next(new Error('Authentication error: Invalid token'));
    }
};