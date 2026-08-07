import SwiftUI

struct SafetyOverlay: View {
    var onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            
            Rectangle()
                .fill(.ultraThinMaterial)
                .colorScheme(.dark)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                HStack(spacing: 15) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.yellow)
                        .font(.system(size: 40))
                    Text(AppStrings.safetyTitle)
                        .font(.largeTitle)
                        .bold()
                        .foregroundStyle(.white)
                }
                .padding(.top, 40)
                
                Divider().background(.white).padding(.horizontal)
                
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(AppStrings.safetyInstructions, id: \.self) { instruction in
                            HStack(alignment: .top, spacing: 15) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                                    .font(.title3)
                                Text(instruction)
                                    .font(.title3)
                                    .foregroundStyle(.white)
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
                .frame(maxWidth: 700, maxHeight: 500)
                
                Spacer()
                
                Button(action: onDismiss) {
                    Text(AppStrings.iUnderstand)
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: 400)
                        .background(Color.yellow)
                        .foregroundStyle(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                }
                .padding(.bottom, 40)
            }
        }
    }
}

