import dotenv from "dotenv";
dotenv.config();
import express from "express";
import helmet from "helmet";
import { createServer } from "http";
import mongoose from "mongoose";
import path from "path";
import { fileURLToPath } from "url";
import authRouter from './routes/auth-router.js';
import imageRouter from './routes/image-router.js';
import userRouter from './routes/user-router.js';
import messageRouter from './routes/message-router.js';
import errorRouter from "./routes/error-router.js";
import notFoundRouter from "./routes/not-found-router.js";
import { runSocketIO } from "./utils/socket.js";

if (
  !process.env.MONGO_USER ||
  !process.env.MONGO_PASSWORD ||
  !process.env.MONGO_DATABASE ||
  !process.env.JWT_SECRET ||
  !process.env.PORT ||
  !process.env.CLIENT_HOST ||
  !process.env.CLIENT_PORT
) {
  console.error("FATAL ERROR: Missing required environment variables.");
  process.exit(1);
}

const MONGODB_URI = `mongodb+srv://${process.env.MONGO_USER}:${process.env.MONGO_PASSWORD}@cluster0.zdmjr.mongodb.net/${process.env.MONGO_DATABASE}?retryWrites=true&w=majority&appName=Cluster0`;

await mongoose.connect(MONGODB_URI);
console.log("\x1b[32mConnected to MongoDB\x1b[0m");

const app = express();

app.use(express.json());

app.use(helmet()); // Security headers

app.use((req, res, next) => {
    res.setHeader('Access-Control-Allow-Origin', `*`);
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
    next();
});

const __filename = fileURLToPath(import.meta.url); // Get the file path
const __dirname = path.dirname(__filename); // Get the directory name
const imagesPath = path.join(__dirname, "..", "images");
app.use("/images", express.static(imagesPath)); // Serves files from images directory

app.use("/upload", imageRouter);

app.use("/auth", authRouter);

app.use("/user", userRouter);

app.use("/message", messageRouter);

app.use(notFoundRouter);

app.use(errorRouter);

const server = createServer(app);

runSocketIO(server);

server.listen(process.env.PORT, () => {
  console.log(`\x1b[32m\Server is listening on port ${process.env.PORT}\x1b[0m`);
});
