#Requires AutoHotkey v2.0
#Include BreakMessage.ahk

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

    _ConfirmGrinderPurchase() {
        this._Execute([
            ["{ENTER}", "Long"],
            ["{ENTER}", "Short"],
            ["{ENTER}", "Long"],
            ["{Esc}",   "Long"]
        ])
    }

    _ToStorageMenu(){
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
            ["{Esc}", "Long"], ; Back to main menu
            ["{Down}", "Short"],
            ["{Down}", "Short"] ; Reset back to hover over 'Excube Exchange shop' button...
        ])
    }

    _ConfirmBuyAndGoBack() {
        this._ConfirmGrinderPurchase()

        ; Open storage and put all stuff in material storage...
        this._ToStorageMenu()
        this._BulkSendMaterialStorage()
        this._GoBackToShopMenu()
    }

    ; Basically, keep buying grinders until any of the state is invalid...
    ; (Usually occurs when material storage runs out of grinders...)
    BuyGrinders() {
        while (true) {
            ; Find the shop menu button on the screen...
            FoundX := 0
            FoundY := 0
            AttemptNumber := 0
            while (not ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, "*255 assets\shop-menu-state.png")) {
                this._ShortRandomSleep()

                ; Failed to find the shop menu button in more than 3 attempts...
                if (AttemptNumber > 3) {
                    breakMsg := BreakMessage(SHOP_BUTTON_STATUS, "'Excube Exchange Shop' button not found!")
                    return breakMsg
                }
                AttemptNumber++
            }

            ; Enter excube exchange shop menu...
            ControlSend("{ENTER}", this.targetWindow)
            ; TODO: Replace with image reconigiton to be 'ready to set to 33' state,'
            ; Rather than rely on a random sleep....
            this._LongRandomSleep()
            this._LongRandomSleep()

            isStorageFull := ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, "*135 assets\full-storage.png")

            if (isStorageFull) {
                this._ShortRandomSleep()
                breakMsg := BreakMessage(GRINDERS_PURCHASE_STATUS, "Unable to use 33 excubes to buy grinders. Material Storage is likely to have full grinders capacity!")
                return breakMsg
            }

            ; Set to maximum possible grinders to purchase
            ControlSend("{Left}", this.targetWindow)
            Sleep(1500)

            this._ConfirmBuyAndGoBack()
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
}