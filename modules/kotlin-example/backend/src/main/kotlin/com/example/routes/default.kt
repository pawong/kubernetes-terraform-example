package com.example.routes

import io.ktor.server.application.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import java.net.InetAddress
import java.time.Instant

fun Application.defaultRouting() {
    routing {
        get("/") { call.respond("{\"Hello\": \"World!\"}") }
        get("/alive") { call.respondText("I'm alive!") }
        get("/health") {
            val gitHash: String = System.getenv("GIT_HASH")
            val hostname: String = InetAddress.getLocalHost().hostName
            val ip_address: String = InetAddress.getLocalHost().hostAddress
            val serverTime: Long = Instant.now().epochSecond
            call.respond(
                    """{
    "git_hash": "${gitHash}",
    "hostname": "${hostname}",
    "ip_address": "${ip_address}",
    "server_time": ${serverTime}
}"""
            )
        }
    }
}
