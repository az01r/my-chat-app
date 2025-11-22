import type { NextFunction, Request, Response } from "express";
import CustomError from "../types/error-type.js";

export default (req: Request, res: Response, next: NextFunction) => {
  console.log('not found router ', req.method, req.path)
  if (req.method === "OPTIONS") {
    return next();
  }
  const error = new CustomError("Page Not Found", 404);
  next(error);
}
