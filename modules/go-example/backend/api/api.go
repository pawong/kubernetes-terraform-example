package main

import (
	"fmt"
	"math/rand/v2"
	"net"
	"net/http"
	"os"
	"time"

	"github.com/gin-gonic/gin"

	_ "api/docs"

	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
)

// @title           Magic 8 Ball API
// @version         1.0
// @description     A simple Magic 8 Ball REST API.
// @host            localhost:8080
// @BasePath        /
func main() {
	router := gin.Default()

	router.GET("/", readRoot)
	router.GET("/keepalive", keepAlive)
	router.GET("/health", health)
	router.GET("/8ball", getAnwserOnly)
	router.POST("/8ball", getAnwser)

	router.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

	err := router.Run("0.0.0.0:8080")
	if err != nil {
		fmt.Printf("Server failed to start: %v", err)
	}
}

// readRoot godoc
// @Summary      Root endpoint
// @Description  Returns a simple hello message.
// @Tags         General
// @Produce      json
// @Success      200  {object}  map[string]string
// @Router       / [get]
func readRoot(c *gin.Context) {
	c.IndentedJSON(http.StatusOK, gin.H{"Hello": "World"})
}

// keepAlive godoc
// @Summary      Keep alive
// @Description  Simple endpoint used to verify the server is responding.
// @Tags         General
// @Produce      plain
// @Success      200  {string} string "I'm alive!"
// @Router       /keepalive [get]
func keepAlive(c *gin.Context) {
	c.Data(
		http.StatusOK,
		"application/json; charset=utf-8",
		[]byte("I'm alive!"),
	)
}

// health godoc
// @Summary      Health check
// @Description  Returns information about the running server.
// @Tags         General
// @Produce      json
// @Success      200  {object} map[string]interface{}
// @Router       /health [get]
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

// getAnwserOnly godoc
// @Summary      Get Magic 8 Ball answer
// @Description  Returns a random Magic 8 Ball answer.
// @Tags         8ball
// @Produce      json
// @Success      200  {string} string
// @Router       /8ball [get]
func getAnwserOnly(c *gin.Context) {
	c.Data(
		http.StatusOK,
		"application/json; charset=utf-8",
		[]byte(answers[rand.IntN(len(answers))]),
	)
}

// getAnwser godoc
// @Summary      Ask the Magic 8 Ball
// @Description  Submit a question and receive a random Magic 8 Ball answer.
// @Tags         8ball
// @Accept       json
// @Produce      json
// @Param        request  body      response  true  "Question"
// @Success      201      {object}  response
// @Failure      400      {object}  map[string]string
// @Router       /8ball [post]
func getAnwser(c *gin.Context) {
	var r response

	if err := c.BindJSON(&r); err != nil {
		return
	}

	r.Answer = answers[rand.IntN(len(answers))]

	c.IndentedJSON(http.StatusCreated, r)
}
