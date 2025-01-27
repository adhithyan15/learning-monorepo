# Powershell
Powershell is a task automation and configuration management framework. It combines the use of a command line shell, a scripting language and a set of tools for managing systems, automations and interacting with apps. It is designed to work directly with objects instead of text based shells. It is also fully cross platform. Powershell scripts are usually made up of one or more cmdlets. 

## Built In CmdLets
### Write-Output
`Write-Output` writes things to stdout. It is often used to pass output from one cmdlet to another cmdlet. It can also be used to write a super simple "Hello World" program. 

```powershell
Write-Output "Hello World"
```

### Write-Host
`Write-Host` writes things to the console or to host that is hosting the powershell script. It can also be used to write a super simple "Hello World" program. 

```powershell
Write-Host "Hello World"
```