package main

import "fmt"

type TerminalLogger struct{}

func (TerminalLogger) Info(msg string) {
	fmt.Println(msg)
}
