#Requires AutoHotkey v2.0

class Debugger {
  static tooltipDuration := 3000
  static path := A_ScriptDir "\logs"

  static Log(message := "Event triggered") {
    timestamp := FormatTime(, "yyyy-MM-dd HH:mm:ss")
    logEntry := "[" timestamp "] " message

    ToolTip(logEntry)
    SetTimer(() => ToolTip(), -Debugger.tooltipDuration)

    if !DirExist(Debugger.path) {
      DirCreate(Debugger.path)
    }

    date := FormatTime(, "yyyy-MM-dd")
    logFile := Debugger.path "\" date ".log"
    FileAppend(logEntry "`n", logFile)
  }
}
