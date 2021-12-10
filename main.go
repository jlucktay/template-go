package main

import (
	"fmt"
	"os"

	"go.jlucktay.dev/version"
)

func main() {
	v, err := version.Details()
	if err != nil {
		fmt.Fprintf(os.Stderr, "could not get version details: %v", err)
		return
	}

	fmt.Println(v)
	fmt.Println()
	fmt.Println("Don't forget to update all instances of 'template-go'! 😅")
}
