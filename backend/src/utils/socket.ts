import { Server as HttpServer } from "http";
import { Server, Socket } from "socket.io";
import { authenticateSocket } from "./socket-auth.js";
import { handlePrivateMessage, handleDisconnect, handleError } from "./socket-controller.js";
import { addUser, getUserSocketId, getOnlineUsers } from './online-users.js';

export const runSocketIO = (server: HttpServer) => {
    const io = new Server(server, {
        cors: {
            origin: [`*`],
            methods: ['GET', 'POST'],
            allowedHeaders: ['Content-Type', 'Authorization'],
            credentials: true // Allow cookies/auth headers if needed later
        },
    });

    // Apply authentication middleware to all incoming connections
    io.use(authenticateSocket);

    io.on('connection', (socket: Socket) => {
        const userId = socket.userId!; // setted in authenticateSocket
        console.log(`Client connected: ${socket.id}, User ID: ${userId}`);
        
        // --- Manage Online Users ---
        // If an online user reconnects (ex: with a new window / device), store the oldSocketId so that it can be disconnected
        const oldSocketId = getUserSocketId(userId);
        // Store/update the socket ID for the user
        addUser(userId, socket.id);
        // If user was already connected disconnect the old socket
        if (oldSocketId && io?.sockets.sockets.get(oldSocketId)) {
            console.log(`User ${userId} reconnected with new socket ${socket.id}, disconnecting old socket ${oldSocketId}`);
            io.sockets.sockets.get(oldSocketId)!.disconnect(true);
        }

        // Optionally: Broadcast to others that this user is online
        // socket.broadcast.emit('user_online', { userId });
        console.log('Online users:', getOnlineUsers());

        socket.on('private_message', handlePrivateMessage(io, socket));

        socket.on('disconnect', handleDisconnect(socket));

        socket.on('error', handleError(socket));
    });
};
