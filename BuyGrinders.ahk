#Requires AutoHotkey v2.0
#Include BreakMessage.ahk
#Include Debugger.ahk
#Include ErrorType.ahk

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
      return this._FindImage("*100 assets\grinder.png", GRINDER_ICON)
    }

    _FindPurchaseAmountSelection() {
      return this._FindImage("*100 assets\purchase-selection.png", GRINDERS_PURCHASE_STATUS)
    }

    _FindPurchaseAmount() {
      return this._FindImage("*100 assets\purchase-amount.png", GRINDERS_PURCHASE_STATUS)
    }

    _FindExcubeAmount() {
      return this._FindImage("*100 assets\excube-amount.png", GRINDERS_PURCHASE_STATUS)
    }

    _FindConfirmationButton() {
      return this._FindImage("*100 assets\confirmation-button.png", CONFIRMATION_BUTTON)
    }

    _FindCloseButton() {
      return this._FindImage("*100 assets\close-button.png", CLOSE_BUTTON)
    }

    _CheckExcubeAmountState() {
      return this._FindExcubeAmount() ; TODO: find the reason of the error and retry if possible
    }

    _CheckShopState() {
      grinder := this._FindGrinderIcon()

      while(not grinder["exists"]) {
        grinder := this._FindGrinderIcon()
      }

      selection := this._FindPurchaseAmountSelection()

      if (not selection["exists"]) {
        return selection["error"]
      }

      return 1
    }

    ; Actual execution
    ;
    _EnterShop() {
      menu := this._FindImage("*100 assets\shop-menu.png", SHOP_BUTTON_STATUS)

      if (not menu["exists"]) {
        return menu["error"]
      }

      this._ExecuteWithDelay([
        ["{ENTER}", "Short"] ; Enter the Excube shop
      ])
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
      this._ExecuteWithDelay([
        ; Select the storage menu
        ["{Up}", "Short"],
        ["{Up}", "Short"],
        ["{ENTER}", "Long"],
        ; Select the Material storage menu
        ["{Down}", "Short"],
        ["{Down}", "Short"],
        ["{ENTER}", "Long"]
      ])

      this._ExecuteWithDelay([
        ; Select yes at the confirmation box
        ["{Left}", "Short"],
        ["{ENTER}", "Short"],
        ; Go Back to the menu shop and restart the loop
        ["{Esc}", "Long"],
        ["{Down}", "Short"],
        ["{Down}", "Short"]
      ])
    }


    ; Utils
    ;
    _FindImage(image, reason) {
      foundX := 0
      foundY := 0
      found := 0
      error := ""
      attempt := 0

      while(not found && attempt <= 3) {
        found := this._KeepTrying(&foundX, &foundY, image)
        this._ShortRandomSleep()
        Debugger.Log("Attempt number: " attempt)
        attempt++
      }

      if (attempt > 3) {
        error := BreakMessage(IMAGE_SEARCH, "Cannot find image. Reason: " reason)
      }

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
        shopMenuState := this._EnterShop()

        if(shopMenuState is BreakMessage) {
          return shopMenuState
        }
        
        shopState := this._CheckShopState()

        if(shopState is BreakMessage) {
          return shopState
        }

        buyState := this._BuyGrinder()

        if (buyState is BreakMessage) {
          return buyState
        }

        closeState := this._CloseShopAndGoBackToMenu()

        if(closeState is BreakMessage) {
          return closeState
        }

        this._LongRandomSleep()
        this._GoToStorageMenu()
      }

      return error
    }

    Start() {
      return this._RunLoop()
    }
}
