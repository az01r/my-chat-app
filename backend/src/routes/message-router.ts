import { Router } from 'express';

import { findByRecipiendAndSenderId } from '../controllers/message-controller.js';
import { isAuth } from '../controllers/auth-controller.js';

const router = Router();

router.get('/with', isAuth, findByRecipiendAndSenderId);

export default router;