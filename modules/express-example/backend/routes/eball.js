var express = require('express');
var router = express.Router();

answers = [
  "It is certain",
  "It is decidedly so",
  "Without a doubt",
  "Yes definitely",
  "You may rely on it",
  "As I see it, yes",
  "Most likely",
  "Outlook good",
  "Yes",
  "Signs point to yes",
  "Reply hazy try again",
  "Ask again later",
  "Better not tell you now",
  "Cannot predict now",
  "Concentrate and ask again",
  "Don't count on it",
  "My reply is no",
  "My sources say no",
  "Outlook not so good",
  "Very doubtful",
]

/**
 * @swagger
 * /8ball:
 *   get:
 *     tags:
 *       - 8 Ball
 *     produces:
 *       - text
 *     description:  Get Magic 8 Ball's answer
 */
router.get('/', function(req, res, next) {
  res.send(answers[Math.floor(Math.random() * answers.length)]);
});

/**
 * @swagger
 * /8ball:
 *   post:
 *     description:  Post question to Magic 8 Ball
 *     tags:
 *       - 8 Ball
 *     produces:
 *       - application/json
 *     requestBody:
 *       description: "Question to ask the Magic 8 Ball"
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - question
 *             properties:
 *               question:
 *                 type: string
 *     responses:
 *       200:
 *         description: Magic 8 Ball, question and answer.
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 question:
 *                   type: string
 *                   description: The question asked.
 *                   example: "Will I win the lottery?"
 *                 answer:
 *                   type: string
 *                   description: The Magic 8 Ball's answer.
 *                   example: It is certain
 */
router.post('/', function(req, res) {
  res.send({
    "question": req.body["question"],
    "answer": answers[Math.floor(Math.random() * answers.length)]
  });
});

module.exports = router;
