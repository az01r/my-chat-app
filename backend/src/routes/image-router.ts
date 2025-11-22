import { Router } from 'express';

import { uploadAvatar, updateUserAvatar } from '../controllers/image-controller.js';
import { isAuth } from '../controllers/auth-controller.js';

const router = Router();

router.post('/avatar', isAuth, uploadAvatar, updateUserAvatar);

export default router;