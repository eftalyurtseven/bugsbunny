package main

import (
	"fmt"
	"net/http"

	"cuelang.org/go/pkg/strconv"
	"github.com/labstack/echo/v4"
)

func main() {
	e := echo.New()

	e.GET("/", handler)

	if err := e.Start(":80"); err != nil {
		fmt.Errorf("e.Start failed w err: %w ", err)
	}
}

// handler handles http request and call factorial calculator function
func handler(c echo.Context) error {
	n := c.QueryParam("number")
	if len(n) == 0 {
		return c.NoContent(http.StatusOK)
	}

	number, err := strconv.ParseInt(n, 10, 64)
	if err != nil {
		return c.String(http.StatusBadRequest, "Number must be a valid integer.")
	}
	r := calc(number)
	if r < 0 {
		return c.String(http.StatusBadRequest, "I know it's bad situation but please send smaller value and don't worry, I'll fix here! :)")
	}
	return c.String(http.StatusOK, fmt.Sprintf("Your result is: %d", r))
}

// calc calculates the factorial of a given number
// note: it doesn't work for big numbers
// TODO: change to math/big
func calc(number int64) int64 {
	if number == 1 || number == 0 {
		return 1
	}
	return number * calc(number-1)
}
