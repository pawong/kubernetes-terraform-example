package com.example.routes

import io.ktor.server.application.*
import io.ktor.server.response.*
import io.ktor.server.routing.*

fun Application.defaultRouting() {
    routing {
        get("/") {
            call.respond("{\"Hello\": \"World!\"}")
        }
        get("/alive") {
            call.respondText("I'm alive!")
        }
        get("/health") {
            call.respond("OK")
        }
    }
}