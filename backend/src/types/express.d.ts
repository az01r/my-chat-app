import 'express';

declare global {
    namespace Express {
        interface Request {
            userId?: string;
        }
    }
}

declare module 'socket.io' {
    interface Socket {
        userId?: string;
    }
}