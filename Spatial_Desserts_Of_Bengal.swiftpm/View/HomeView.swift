import SwiftUI

struct HomeView: View {
    @Binding var mode: Int
    @State var showSet = false
    @State var vol: Float = 0.5
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                if UIImage(named: AppIcons.homeBg) != nil {
                    Image(AppIcons.homeBg)
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                } else {
                    LinearGradient(colors: [Pal.cRedTop, Pal.cTabBot], startPoint: .top, endPoint: .bottom)
                        .ignoresSafeArea()
                }
                
                
                VStack(spacing: 40) {
                    
                    
                    VStack(spacing: 15) {
                        
                        Text(AppStrings.appTitle)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 80, weight: .black, design: .rounded))
                            .minimumScaleFactor(0.3)
                            .lineLimit(2)
                            .foregroundStyle(Pal.cGold)
                            .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 4)
                            .padding(.horizontal)
                        
                        
                        Text(AppStrings.appSubtitle)
                            .font(.title3.bold())
                            .minimumScaleFactor(0.5)
                            .lineLimit(2)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                            .background(
                                RoundedRectangle(cornerRadius: AppLayout.cornerMed)
                                    .fill(Pal.cRedBot)
                                    .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 3)
                            )
                            .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 20)
                    
                    Button(action: { mode = 1 }) {
                        Label(AppStrings.playGame, systemImage: "play.fill")
                            .font(.title2.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.extraLarge)
                    .tint(Pal.cRedBot)
                    .padding(.horizontal, 60)
                    .shadow(radius: 5)
                    
                    Button(action: { mode = 4 }) {
                        Label(AppStrings.collection, systemImage: "square.grid.2x2.fill")
                            .font(.title3.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .tint(.white)
                    .background(.ultraThinMaterial, in: Capsule())
                    .padding(.horizontal, 80)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: { showSet = true }) {
                        
                            Image(systemName: "music.note")
                                .font(.title)
                                .foregroundStyle(.white)
                                .padding()
                                .background(Circle().fill(.ultraThinMaterial))
                        }
                    }
                }
            }
            .sheet(isPresented: $showSet) {
                NavigationStack {
                    Form {
                        Section("Audio Settings") {
                            HStack {
                                Image(systemName: "speaker.wave.2.fill")
                                Slider(value: $vol, in: 0...1)
                                    .onChange(of: vol) { oldValue, newValue in
                                        AuMgr.shared.setVolume(newValue)
                                    }
                            }
                        }
                    }
                    .navigationTitle(AppStrings.settings)
                    .toolbar {
                        Button("Done") { showSet = false }
                    }
                }
                .presentationDetents([.medium])
            }
        }
    }
}

