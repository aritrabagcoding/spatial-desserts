import SwiftUI

struct ARTutorialView: View {
    var onDismiss: () -> Void
    var body: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()
            VStack(spacing: 25) {
                Text(AppStrings.arTraining).font(.largeTitle).bold().foregroundStyle(.cyan)
                VStack(spacing: 5) {
                    Text(AppStrings.arScanInst).foregroundStyle(.white)
                    Text(AppStrings.arVoiceHeader).bold().foregroundStyle(.cyan).padding(.top, 5)
                    
                    Text(AppStrings.arCmdNav).foregroundStyle(.white).font(.caption)
                    Text(AppStrings.arCmdMove).foregroundStyle(.white).font(.caption)
                    Text(AppStrings.arCmdScale).foregroundStyle(.white).font(.caption)
                    Text(AppStrings.arCmdRotate).foregroundStyle(.white).font(.caption)
                }
                Button(AppStrings.startMission, action: onDismiss)
                    .padding()
                    .background { Color.cyan }
                    .foregroundStyle(.black)
                    .clipShape(RoundedRectangle(cornerRadius: AppLayout.cornerMed))
            }
        }
    }
}

