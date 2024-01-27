var express = require('express');
var router = express.Router();

/* GET: Default route */
router.get('/', function(req, res, next) {
  res.render('index', { title: 'Express' });
});

/**
 * @swagger
 * /alive:
 *   get:
 *     summary: Keep alive
 *     description:  Keep alive endpoint
 *     tags:
 *       - default
 *     produces:
 *       - string
 *     responses:
 *       200:
 *         description: Keep alive response
 *         content:
 *           string:
 *             schema:
 *               type: string
 */
router.get('/alive', function(req, res, next) {
  res.send('I\'m alive!')
});

module.exports = router;
