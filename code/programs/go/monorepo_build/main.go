package main

func main() {
	context := GetBuildContext()
	context.logger.Info("Hello, world!")
}
