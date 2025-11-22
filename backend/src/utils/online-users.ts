// Connected users: userId -> socketId
const onlineUsersMap: { [userId: string]: string } = {};

/**
 * Adds or updates a user's primary socket ID.
 */
export const addUser = (userId: string, socketId: string): void => {
    onlineUsersMap[userId] = socketId;
};

/**
 * Removes a user from the online list.
 * Returns true if the user was removed, false otherwise.
 */
export const removeUser = (userId: string, socketId: string): boolean => {
    if (onlineUsersMap[userId] === socketId) {
        delete onlineUsersMap[userId];
        return true;
    }
    return false;
};

/**
 * Retrieves the primary socket ID for a given user.
 */
export const getUserSocketId = (userId: string): string | undefined => {
    return onlineUsersMap[userId];
};

/**
 * Returns a snapshot of the current online users map.
 */
export const getOnlineUsers = (): { [userId: string]: string } => {
    return onlineUsersMap;
}