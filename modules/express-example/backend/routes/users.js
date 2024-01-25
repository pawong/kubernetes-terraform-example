var express = require('express');
var router = express.Router();

/**
 * @swagger
 * /users:
 *   get:
 *     description:  Users Listing
 *     tags:
 *       - users
 */

/**
 * @swagger
 * /users:
 *   get:
 *     summary: Get list of Users
 *     description:  Users Listing
 *     tags:
 *       - users
 *     produces:
 *       - string
 *     responses:
 *       200:
 *         description: List of users.
 *         content:
 *           string:
 *             schema:
 *               type: string
 */
router.get('/', function(req, res, next) {
  res.send('respond with a resource for users endpoint');
});

module.exports = router;
