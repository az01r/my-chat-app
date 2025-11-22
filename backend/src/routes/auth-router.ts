import { Router } from 'express';

import { login, signup } from '../controllers/auth-controller.js';
import { loginValidation, signupValidation } from '../utils/auth-validator.js';
import { validateRequest } from '../controllers/validation-controller.js';

const router = Router();

router.post('/signup', signupValidation, validateRequest, signup);

router.post('/login', loginValidation, validateRequest, login);

export default router;