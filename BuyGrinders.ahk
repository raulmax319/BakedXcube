#Requires AutoHotkey v2.0
#Include BreakMessage.ahk
#Include Debugger.ahk

SHOP_BUTTON_STATUS := "SHOP BUTTON"
GRINDERS_PURCHASE_STATUS := "GRINDERS PURCHASE"

class GrindersBuyer {
    __New(targetWindow) {
      this.targetWindow := targetWindow
    }

    _LongRandomSleep() {
      randomTime := Random(1000, 1400)
      Sleep(randomTime)
    }

    _ShortRandomSleep() {
      randomTime := Random(450, 525)
      Sleep(randomTime)
    }

    _FindImage(&outputX, &outputY, image) {
      CoordMode("Pixel", "Window")
      return ImageSearch(&outputX, &outputY, 0, 0, A_ScreenWidth, A_ScreenHeight, image)
    }

    _EnterShop() {
      foundX := 0
      foundY := 0
      found := false

      while(not found) {
        try {
          found := this._FindImage(&foundX, &foundY, "*200 assets\shop-menu.png")
          
          if (found) {
            Debugger.Log("Found image at X: " foundX ", Y: " foundY)
          } else {
            Debugger.Log("Couldn't find image. X: " foundX ", Y: " foundY)
          }
        } catch as exc
          message := "Couldn't search for image. Reason: `n" exc.Message
          Debugger.Log(message)
          return BreakMessage(
            SHOP_BUTTON_STATUS,
            message
          )
      }
    }

    _ConfirmGrinderPurchase() {
      this._Execute([
        ["{Left}", "Long"],
        ["{ENTER}", "Long"],
        ["{ENTER}", "Short"],
        ["{ENTER}", "Long"],
        ["{Esc}", "Long"]
      ])
    }

    _ToStorageMenu() {
      this._Execute([
        ["{Up}", "Short"],
        ["{Up}", "Short"],
        ["{ENTER}", "Short"]
      ])
    }

    _BulkSendMaterialStorage() {
        this._Execute([
          ["{Down}", "Short"],
          ["{Down}", "Short"],
          ["{ENTER}", "Long"],
          ["{Left}", "Short"],
          ["{ENTER}", "Short"]
        ])
    }

    _GoBackToShopMenu() {
      this._Execute([
        ["{Esc}", "Long"],
        ["{Down}", "Short"],
        ["{Down}", "Short"]
      ])
    }

    _BuyGrinders() {
      this._ConfirmGrinderPurchase()
      this._ToStorageMenu()
      this._BulkSendMaterialStorage()
      this._GoBackToShopMenu()
    }

    _RunLoop() {
      canStillGo := true
      while (canStillGo) {
        canStillGo := this._EnterShop()
        ; this._BuyGrinders()
      }
    }

    _Execute(actions) {
      for index, pair in actions {
        ControlSend(pair[1], this.targetWindow)

        if (pair[2] == "Short") {
          this._ShortRandomSleep()
        } else {
          this._LongRandomSleep()
        }
      }
    }

    Start() {
      this._RunLoop()
    }
}
