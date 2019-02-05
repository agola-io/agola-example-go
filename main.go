package main

import (
	"fmt"

	"rsc.io/quote"
)

func main() {
	// we use an external go module
	fmt.Println(quote.Hello())
}
