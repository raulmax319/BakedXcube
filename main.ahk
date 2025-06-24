#Requires AutoHotkey v2.0
#Include Debugger.ahk
#Include BreakMessage.ahk
#Include BuyGrinders.ahk

programName := "PHANTASY STAR ONLINE 2 NEW GENESIS"
windows := WinGetList(programName)

if (windows.Length > 0) {
    targetWindow := windows[1]
    WinActivate(targetWindow)
    Debugger.Log("Application Started.")
    Sleep(1000)
} else {
    MsgBox("PSO2 not found. Exiting...")
    Sleep(3000)
    ExitApp()
}

controllerState := GrindersBuyer(targetWindow)
breakMsg := controllerState.Start()

if (breakMsg is BreakMessage) {
  MsgBox(breakMsg.message)
} else {
  MsgBox("Tudo aconteceu corretamente.")
}

ExitApp()