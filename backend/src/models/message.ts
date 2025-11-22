import mongoose, { Document, Types } from 'mongoose';

const Schema = mongoose.Schema;

export interface IMessage extends Document {
    sender: Types.ObjectId;
    recipient: Types.ObjectId;
    content: string;
    createdAt: Date;
    updatedAt: Date;
    read: boolean;
}

const messageSchema = new Schema<IMessage>(
    {
        sender: { type: Schema.Types.ObjectId, ref: 'User', required: true },
        recipient: { type: Schema.Types.ObjectId, ref: 'User', required: true },
        content: { type: String, required: true },
        read: { type: Boolean, default: false },
    },
    { timestamps: true }
);

const Message = mongoose.model<IMessage>('Message', messageSchema);

export default Message;