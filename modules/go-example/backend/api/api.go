package main

import (
	"fmt"
	"math/rand/v2"
	"net"
	"net/http"
	"os"
	"time"

	"github.com/gin-gonic/gin"
)

func main() {
	router := gin.Default()
	router.GET("/", readRoot)
	router.GET("/keepalive", keepAlive)
	router.GET("/health", health)

	router.GET("/8ball", getAnwserOnly)
	router.POST("/8ball", getAnwser)

	err := router.Run("0.0.0.0:8080")
	if err != nil {
		fmt.Printf("Server failed to start: %v", err)
	}
}

func readRoot(c *gin.Context) {
	c.IndentedJSON(http.StatusOK, gin.H{"Hello": "World"})
}

func keepAlive(c *gin.Context) {
	c.Data(http.StatusOK, "application/json; charset=utf-8", []byte("I'm alive!"))
}

func health(c *gin.Context) {
	hostname, _ := os.Hostname()
	ip, _ := net.LookupIP(hostname)
	c.IndentedJSON(
		http.StatusOK,
		gin.H{
			"git_hash":    os.Getenv("GIT_HASH"),
			"hostname":    hostname,
			"ip_address":  ip[0],
			"server_time": time.Now().Unix(),
		},
	)
}

var answers = [...]string{
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
}

type response struct {
	Question string `json:"question"`
	Answer   string `json:"answer"`
}

func getAnwserOnly(c *gin.Context) {
	c.Data(http.StatusOK, "application/json; charset=utf-8", []byte(answers[rand.IntN(len(answers))]))
}

func getAnwser(c *gin.Context) {
	var r response
	if err := c.BindJSON(&r); err != nil {
		return
	}
	r.Answer = answers[rand.IntN(len(answers))]
	c.IndentedJSON(http.StatusCreated, r)
}
