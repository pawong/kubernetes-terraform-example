package com.example.routes

import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import io.ktor.serialization.kotlinx.json.*

import kotlinx.serialization.*
import kotlinx.serialization.json.*

val answers = arrayOf(
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
)

@Serializable
data class Question(val question: String = "", val answer: String = "")

fun Application.eightBallRouting() {
    routing {
        get("/8ball") {
            call.respondText(answers[(Math.floor(Math.random() * answers.size)).toInt()])
        }
        post("/8ball") {
            val question = call.receive<Question>()
            call.respond(Question(
                question.question, answers[(Math.floor(Math.random() * answers.size)).toInt()]
            ))
        }
    }
}