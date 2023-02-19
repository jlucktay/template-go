package main

import (
	"fmt"

	"go.jlucktay.dev/version"
)

func main() {
	fmt.Println(version.Details())
	fmt.Println()
	fmt.Println("Don't forget to update all instances of 'template-go'! 😅")
}
