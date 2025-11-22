import mongoose, { Document, Schema, Types } from 'mongoose';

export interface IUser extends Document {
    _id: Types.ObjectId;
    nickname: string;
    email: string;
    password: string;
    avatar?: string;
    contacts: Types.ObjectId[];
    timestamp: Date;
}

const userSchema = new Schema(
    {
        nickname: { type: String, required: true, unique: true },
        email: { type: String, required: true, unique: true },
        password: { type: String, required: true },
        avatar: { type: String },
        contacts: [{ type: Schema.Types.ObjectId, ref: 'User' }],
    },
    { timestamps: true }
);

const User = mongoose.model<IUser>('User', userSchema);

export default User;