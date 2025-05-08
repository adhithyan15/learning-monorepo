package main

type BuildContext struct {
	logger Logger
}

func GetBuildContext() BuildContext {
	return BuildContext{
		logger: TerminalLogger{},
	}
}
