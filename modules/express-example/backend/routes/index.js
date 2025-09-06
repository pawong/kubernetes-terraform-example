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

/**
 * @swagger
 * /health:
 *   get:
 *     summary: Health
 *     description:  Health Check endpoint
 *     tags:
 *       - default
 *     produces:
 *       - string
 *     responses:
 *       200:
 *         description: Health Check response
 *         content:
 *           string:
 *             schema:
 *               type: string
 */
router.get('/health', function(req, res, next) {
  const os = require('os');
  var ip = require("ip");
  const ip_address = ip.address()
  const serverHostname = os.hostname();
  const git_hash = process.env.GIT_HASH;
  const epochSeconds = Math.floor(Date.now() / 1000);
  res.send({
    "git_hash": git_hash,
    "hostname": serverHostname,
    "ip_address": ip_address,
    "server_time": epochSeconds,
  })
});


module.exports = router;
