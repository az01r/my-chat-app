import { Router } from 'express';

import { findByEmail, findById, getContacts } from '../controllers/user-controller.js';
import { isAuth } from '../controllers/auth-controller.js';

const router = Router();

router.get('/findByEmail', isAuth, findByEmail);

router.get('/findById', isAuth, findById);

router.get('/contacts', isAuth, getContacts);

export default router;