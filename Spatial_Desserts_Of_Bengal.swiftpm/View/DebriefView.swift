import SwiftUI

struct DebriefView: View {
    @Bindable var currentRecipe: RecipeModel
    var onFin: () -> Void
    var onHome: () -> Void 
    
    @State private var vm = DebriefViewModel()
    @State private var showConfirmAlert = false
    
    var body: some View {
        ZStack {
            
            Pal.cTabTop.ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button(action: onHome) {
                        HStack {
                            Image(systemName: "house.fill")
                            Text("Home")
                        }
                        .font(.headline)
                        .foregroundStyle(Pal.cBrnTxt)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Capsule().fill(Color.white))
                        .shadow(radius: 2)
                    }
                }
                .padding()
                Spacer()
                VStack(spacing: 25) {
                    Text("SENTIMENT ANALYSIS BASED FEEDBACK")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(Pal.cBrnTxt)
                        .padding(.top, 20)
                    Text("How did the cooking go?")
                        .font(.subheadline)
                        .foregroundStyle(Pal.cBrnTxt.opacity(0.8))
                    TextField(AppStrings.commentsPlaceholder, text: $vm.feedbackText, axis: .vertical)
                        .textFieldStyle(.plain)
                        .padding()
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Pal.cTabBot.opacity(0.3), lineWidth: 1))
                        .frame(height: 120)
                        .padding(.horizontal)
                    
                    Button(action: {
                        if !vm.feedbackText.isEmpty {
                            showConfirmAlert = true
                        }
                    }) {
                        Text(AppStrings.submitLog)
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(vm.feedbackText.isEmpty ? Color.gray : Pal.cRedBot)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(radius: 3)
                    }
                    .disabled(vm.feedbackText.isEmpty)
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
                .background(Color.white.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(radius: 5)
                .padding()
                
                Spacer()
            }
        }
        .alert("Submit Feedback?", isPresented: $showConfirmAlert) {
            Button("No", role: .cancel) { }
            Button("Yes") {
                Task {
                    await vm.analyzeSentiment(for: currentRecipe, onComplete: onFin)
                }
            }
        } message: {
            Text("Do you really wish to submit this review?")
        }
    }
}

