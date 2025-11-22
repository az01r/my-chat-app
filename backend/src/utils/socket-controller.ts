import Message from '../models/message.js';
import { Server, Socket } from "socket.io";
import { getUserSocketId, getOnlineUsers, removeUser } from './online-users.js';
import User, { type IUser } from '../models/user.js';
import { Types, Document } from 'mongoose';

interface PrivateMessagePayload {
    recipientUserId: string;
    message: string;
}

type UserDocument = IUser & Document;

export const handlePrivateMessage = (io: Server, socket: Socket) => {
    return async (payload: PrivateMessagePayload, callback?: (ack: any) => void) => {
        const senderId = socket.userId;
        const { recipientUserId, message } = payload;

        if (!senderId || !recipientUserId || !message) {
            console.error('Error sending message: Missing senderId, recipientUserId or message.');
            if (callback) callback({ success: false, error: 'Server Error: Missing senderId, recipientUserId or message on handlePrivateMessage.' });
            return;
        }

        console.log(`Message from ${senderId} to ${recipientUserId}: ${message}`);

        try {
            const sender: UserDocument | null = await User.findById(senderId);
            if (!sender) {
                throw Error('Sender not found');
            }
            if (!sender.contacts.find(c => c.toString() === recipientUserId)) {
                sender.contacts.push(new Types.ObjectId(recipientUserId));
                await sender.save();
            }
            const recipient: UserDocument | null = await User.findById(recipientUserId);
            if (!recipient) {
                throw Error('Recipient not found');
            }
            if (!recipient.contacts.find(c => c.toString() === senderId)) {
                recipient.contacts.push(new Types.ObjectId(senderId));
                await recipient.save();
            }

            const newMessage = new Message({
                sender: senderId,
                recipient: recipientUserId,
                content: message,
            });
            await newMessage.save();
            console.log(`Message saved to DB: ${newMessage}`);

            // --- Send to Recipient if Online ---
            const recipientSocketId = getUserSocketId(recipientUserId);
            if (recipientSocketId) {
                console.log(`Sending message to recipient ${recipientUserId} via socket ${recipientSocketId}`);
                io?.to(recipientSocketId).emit('receive_private_message', {
                    senderUserId: senderId,
                    messageId: newMessage._id.toString(), // Send message ID as well
                    message: message,
                    createdAt: newMessage.createdAt
                });
            } else {
                console.log(`Recipient ${recipientUserId} is offline.`);
                // Handle offline message logic here (e.g., push notification, mark as unread)
            }

            // --- Send confirmation back to sender ---
            if (callback) {
                callback({
                    success: true,
                    messageId: newMessage._id.toString(),
                    createdAt: newMessage.createdAt
                });
            }

        } catch (error) {
            console.error('Error saving or sending message:', error);
            if (callback) callback({ success: false, error: 'Server error saving message' });
        }
    }
}

export const handleDisconnect = (socket: Socket) => {
    return (reason: string) => {
        console.log(`Client disconnected: ${socket.id}, User ID: ${socket.userId!}, Reason: ${reason}`);
        removeUser(socket.userId!, socket.id);
        console.log('Online users:', getOnlineUsers());
    }
}

export const handleError = (socket: Socket) => {
    return (err: Error) => {
        console.error(`Socket Error on ${socket.id} (User: ${socket.userId}):`, err);
    }
}