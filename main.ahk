#Requires AutoHotkey v2.0
#Include Debugger.ahk
#Include BreakMessage.ahk
#Include BuyGrinders.ahk

programName := "PHANTASY STAR ONLINE 2 NEW GENESIS"
programid := WinGetList(programName)
targetWindow := 0

Sleep(100)
; Find and focus on window
if (programid.Length > 0) {
    targetWindow := programid[1]
    WinActivate(targetWindow)
    Debugger.Log("Application Started.")
    Sleep(1000)
} else {
    Debugger.Log("Could not find PSO2. Exiting.")
    Sleep(5000)
    ExitApp()
}

controllerState := GrindersBuyer(targetWindow)
breakMsg := controllerState.Start()

if (breakMsg) {
  MsgBox(breakMsg.message)
} else {
  MsgBox("Tudo aconteceu corretamente.")
}

ExitApp()