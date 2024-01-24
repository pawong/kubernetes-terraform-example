var express = require('express');
var router = express.Router();

/**
 * @swagger
 * /users:
 *   get:
 *     tags:
 *       - users
 *     description:  Users Listing
 */
router.get('/', function(req, res, next) {
  res.send('respond with a resource for users endpoint');
});

module.exports = router;
