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

if (breakMsg.status == SHOP_BUTTON_STATUS) {
    MsgBox(breakMsg.message)
    ExitApp()
}

if (breakMsg.status == GRINDERS_PURCHASE_STATUS) {
    MsgBox(breakMsg.message)
    ; TODO: Blind path navigate to shop to sell all grinders.
    ; Then check if the player still has enough excubes to buy grinders...
}

ExitApp()