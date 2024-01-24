var express = require('express');
var router = express.Router();

/**
 * @swagger
 * /:
 *   get:
 *     description:  Home page
 */
router.get('/', function(req, res, next) {
  res.render('index', { title: 'Express' });
});

module.exports = router;
