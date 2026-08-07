import SwiftUI


struct AppStrings {
    
    static let appTitle = "SPATIAL DESSERTS\nOF BENGAL"
    static let appSubtitle = "Get a sneak peek into the future of cooking"
    static let back = "BACK"
    static let loading = "Loading..."
    static let settings = "SETTINGS"
    
    
    static let playGame = "START COOKING"
    static let collection = "COLLECTION"
    static let served = "SERVED"
    static let inProgress = "IN PROGRESS"
    static let notStarted = "NOT STARTED"
    
    static let savedToast = "Progress Saved"
    static let dishServed = "PUZZLE COMPLETED"
    static let startCooking = "START COOKING"
    static let yourMenu = "YOUR MENU"
    
    static let scanSurface = "Move iPad to scan your table..."
    static let tapToPlace = "TAP SCREEN TO PLACE KITCHEN"
    static let placeWarning = "Place kitchen first to use controls"
    static let arTraining = "SPATIAL DESSERTS GUIDE"
    static let arScanInst = "Scan Surface -> Tap to Place"
    
    static let edit = "EDIT"
    static let reset = "RESET"
    static let done = "DONE"
    static let longPressToSelect = "Long press a panel to edit height"
    static let heightLabel = "Height"
    static let editingSelected = "Editing: "
    
    static let arVoiceHeader = "How to use:"
    static let arCmdNav = "• Tap buttons inside instruction panel to navigate"
    static let arCmdMove = "• Drag panels to move"
    static let arCmdScale = "• Pinch to resize"
    static let arCmdRotate = "• Twist with two fingers to rotate"
    static let startMission = "START"
    static let safetyTitle = "KITCHEN SAFETY"
    static let iUnderstand = "I UNDERSTAND & AGREE"
    static let safetyInstructions = [
        "Ensure your cooking space is clear of trip hazards.",
        "Keep the iPad away from open flames and hot surfaces.",
        "When needed place the device only on a stable and dry surface.",
        "Make sure to keep your eyes on the stove.",
        "Maintain awareness of your physical surroundings",
        "Put down knives before interacting with the UI.",
        "Pause the app if you need to focus on a critical step."
    ]
    
    static let cameraDenied = "Camera Access Required for AR"
    static let rateSync = "SENTIMENT ANALYSIS BASED FEEDBACK"
    static let commentsPlaceholder = "Recipe will be auto-categorised based on your feedback"
    static let submitLog = "SAVE FEEDBACK"
    static let letsCook = "LET'S COOK"
}

struct AppLayout {
    static let cornerSmall: CGFloat = 8
    static let cornerMed: CGFloat = 12
    static let cornerLarge: CGFloat = 16
    static let cornerXL: CGFloat = 30
    static let iconSmall: CGFloat = 20
    static let iconSettings: CGFloat = 44
    static let iconMed: CGFloat = 40
    static let iconLarge: CGFloat = 80
    static let strokeWidth: CGFloat = 4
    static let hudHeight: CGFloat = 60
}

struct AppIcons {
    static let homeBg = "home_bg"
    static let save = "square.and.arrow.down.fill"
    static let close = "xmark.circle.fill"
}

struct AppLogic {
    struct EntityNames {
        static let questPanel = "INSTRUCTION PANEL"
        static let timerPanel = "TIMER PANEL"
        static let ingPanel = "INGREDIENTS PANEL"
        static let stepText = "stxt"
        static let suggText = "txt_sugg"
        
        static let timerHeader = "tmr_header"
        static let timerBarBg = "tmr_bg"
        static let timerBarFg = "tmr_fg"
        
        static let btnNext = "btn_next"
        static let btnPrev = "btn_prev"
        static let dishStamp = "img_dish"
    }
}

