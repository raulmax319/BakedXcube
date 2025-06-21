#Requires AutoHotkey v2.0

; Model to signal to main loop what happened to cause
; other functionalities to break...
class BreakMessage {
    __New(status, message) {
        this.status := status
        this.message := message
    }
}