#Requires AutoHotkey v2.0
#Include BreakMessage.ahk
#Include Debugger.ahk

SHOP_BUTTON_STATUS := "SHOP BUTTON"
GRINDERS_PURCHASE_STATUS := "GRINDERS PURCHASE"
IMAGE_SEARCH := "IMAGE SEARCH"

class GrindersBuyer {
    __New(targetWindow) {
      this.targetWindow := targetWindow
    }

    _ShortRandomSleep() {
      randomTime := Random(450, 525)
      Sleep(randomTime)
    }

    _LongRandomSleep() {
      randomTime := Random(525, 1000)
      Sleep(randomTime)
    }

    _FindGrinderIcon() {
      return this._FindImage("*100 assets\grinder.png")
    }

    _FindPurchaseAmountSelection() {
      return this._FindImage("*100 assets\purchase-selection.png")
    }

    _FindPurchaseAmount() {
      return this._FindImage("*100 assets\purchase-amount.png")
    }

    _FindExcubeAmount() {
      return this._FindImage("*100 assets\excube-amount.png")
    }

    _FindConfirmationButton() {
      return this._FindImage("*100 assets\confirmation-button.png")
    }

    _FindCloseButton() {
      return this._FindImage("*100 assets\close-button.png")
    }

    _FindStorageMenu() {
      return this._FindImage("*100 assets\storage-menu.png")
    }

    _FindMaterialStorageMenu() {
      this._FindImage("*100 assets\material-storage-menu.png")
    }

    _CheckExcubeAmountState() {
      return this._FindExcubeAmount() ; TODO: find the reason of the error and retry if possible
    }

    _CheckShopState() {
      grinder := this._FindGrinderIcon()

      if (not grinder["exists"]) {
        return grinder
      }

      selection := this._FindPurchaseAmountSelection()

      if (not selection["exists"]) {
        return selection
      }

      return Map(
          "exists", true,
          "error", ""
        )
    }

    ; Actual execution
    ;
    _EnterShop() {
      menu := this._FindImage("*100 assets\shop-menu.png")

      if (menu["exists"]) {
        this._ExecuteWithDelay([
          ["{ENTER}", "Short"] ; Enter the Excube shop
        ])
      }

      return menu
    }

    _SelectMaximumGrinderAmount() {
      this._Execute("{left}")
      this._ShortRandomSleep()

      return this._FindPurchaseAmount()
    }

    _BuyGrinder() {
      grinderAmount := this._SelectMaximumGrinderAmount()

      if (not grinderAmount["exists"]) {
        return grinderAmount["error"]
      }

      excubeAmount := this._CheckExcubeAmountState()

      if (not excubeAmount["exists"]) {
        return excubeAmount["error"]
      }

      this._ExecuteWithDelay([
        ["{ENTER}", "Short"] ; Enter the purchase confirmation box
      ])

      button := this._FindConfirmationButton()

      if (not button["exists"]) {
        return button["error"]
      }

      this._ExecuteWithDelay([
        ["{ENTER}", "Short"] ; Confirm Purchase
      ])
    }

    _CloseShopAndGoBackToMenu() {
      button := this._FindCloseButton()

      if (not button["exists"]) {
        return button["error"]
      }

      this._ExecuteWithDelay([
        ["{ENTER}", "Short"],
        ["{Esc}", "Short"],
      ])
    }

    ; Kinda mechanic method without much image search
    ; But its just menu swap so it works
    _GoToStorageMenu() {
      storage := this._FindStorageMenu()

      if (not storage["exists"]) {
        return storage["error"]
      }

      this._ExecuteWithDelay([
        ["{Up}", "Short"],
        ["{Up}", "Short"],
        ["{ENTER}", "Long"]
      ])
      
      materialStorage := this._FindMaterialStorageMenu()

      if (not materialStorage["exists"]) {
        return materialStorage["error"]
      }

      ; Bulk send to material storage
      this._ExecuteWithDelay([
        ["{Down}", "Short"],
        ["{Down}", "Short"],
        ["{ENTER}", "Long"],
        ["{Left}", "Short"],
        ["{ENTER}", "Short"],
        ["{Esc}", "Long"],
        ["{Down}", "Short"],
        ["{Down}", "Short"] ; Go back to shop menu
      ])
    }


    ; Utils
    ;
    _FindImage(image) {
      foundX := 0
      foundY := 0
      found := 0
      error := ""

      while(not found) {
        found := this._KeepTrying(&foundX, &foundY, image)
        SetTimer(() => {}, 500)
      }

      Debugger.Log("Found image at X: " foundX ", Y: " foundY)

      return Map(
        "x", foundX,
        "y", foundY,
        "exists", found,
        "error", error
      )
    }

    _KeepTrying(&foundX, &foundY, image) {
      found := false

      Debugger.Log("Searching for: " image)
      return this._SearchImage(&foundX, &foundY, image)
    }

    _SearchImage(&outputX, &outputY, image) {
      CoordMode("Pixel", "Window")
      return ImageSearch(&outputX, &outputY, 0, 0, A_ScreenWidth, A_ScreenHeight, image)
    }

    _Execute(action) {
      ControlSend(action, this.targetWindow)
    }

    _ExecuteWithDelay(actions) {
      for index, pair in actions {
        ControlSend(pair[1], this.targetWindow)
        if (pair[2] == "Short") {
          this._ShortRandomSleep()
        } else {
          this._LongRandomSleep()
        }
      }
    }

    _RunLoop() {
      error := ""
      while (1) {
        shop := this._EnterShop()

        if(not shop["exists"]) {
          error := shop["error"]
          break
        }
        
        state := this._CheckShopState()

        if(not state["exists"]) {
          error := state["error"]
          break
        }

        this._BuyGrinder()
        this._CloseShopAndGoBackToMenu()
        this._LongRandomSleep()
        this._GoToStorageMenu()
        break
      }

      return error
    }

    Start() {
      return this._RunLoop()
    }
}
