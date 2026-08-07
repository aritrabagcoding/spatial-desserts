import SwiftUI
import SpriteKit

struct GameView: View {
    @Binding var mode: Int
    @Bindable var currentRecipe: RecipeModel
    @State private var vm = GameViewModel()
    
    var body: some View {
        ZStack {
            content
        }
        .onAppear {
            if currentRecipe.status == 2 {
                vm.subMode = 1
            }
        }
    }
    
    var content: some View {
        ZStack {
            if vm.subMode == 0 {
                SpriteView(scene: vm.getPuzzleScene(for: currentRecipe))
                    .ignoresSafeArea()
                VStack {
                    headerControls
                    Spacer()
                }
                if vm.showSaveToast {
                    Text(AppStrings.savedToast).bold().padding().background { Color.black.opacity(0.7) }.foregroundStyle(.white).clipShape(RoundedRectangle(cornerRadius: 10))
                }
            } else if vm.subMode == 1 {
                transitionScreen
            } else if vm.subMode == 2 {
                arLayer
            } else {
                DebriefView(
                    currentRecipe: currentRecipe,
                    onFin: { mode = 1 },
                    onHome: { mode = 0 }
                )
            }
        }
    }
    
    var headerControls: some View {
        HStack {
            Button(AppStrings.back) { vm.savePuzzle(for: currentRecipe); mode = 1 }
                .padding().background { Color.white }.clipShape(RoundedRectangle(cornerRadius: AppLayout.cornerSmall))
            GeometryReader { g in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white).frame(height: AppLayout.hudHeight).overlay { Capsule().stroke(Color.gray, lineWidth: 1) }
                    Capsule()
                        .fill(currentRecipe.col)
                        .frame(width: g.size.width * CGFloat(vm.puzzleProgress), height: 12)
                        .padding(.horizontal, 2)
                }
            }.frame(height: AppLayout.hudHeight).padding(.horizontal)
            Button(action: { vm.savePuzzle(for: currentRecipe) }) {
                Image(systemName: AppIcons.save).font(.largeTitle).foregroundStyle(Color.yellow)
            }
        }.padding()
    }
    
    var transitionScreen: some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea()
            VStack(spacing: 20) {
                Text(AppStrings.dishServed).foregroundStyle(Color.yellow).font(.largeTitle)
                Text(currentRecipe.name).foregroundStyle(.white)
                
                Button(AppStrings.startCooking) { vm.startARSession() }
                    .padding()
                    .background { Color.blue }
                    .foregroundStyle(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                Button("Back to Menu") { mode = 1 }
                    .padding()
                    .foregroundStyle(.gray)
            }
        }
    }
    
    var arLayer: some View {
        ZStack {
            ARCookingView(
                recipe: currentRecipe,
                reticleColor: $vm.reticleColor,
                onExit: vm.exitAR,
                isContentPlaced: $vm.isContentPlaced,
                showLookUpHint: $vm.showLookUpHint,
                vm: vm
            )
            .ignoresSafeArea()
            
            if !vm.isContentPlaced {
                Circle().stroke(vm.reticleColor, lineWidth: 2)
                    .frame(width: AppLayout.iconSmall, height: AppLayout.iconSmall)
            }
            
            
            if vm.showARTutorial {
                ARTutorialView {
                    withAnimation {
                        vm.showARTutorial = false
                        vm.showSafetyOverlay = true
                    }
                }.zIndex(20)
            } else if vm.showSafetyOverlay {
                SafetyOverlay {
                    withAnimation { vm.showSafetyOverlay = false }
                }.zIndex(20)
            } else {
                activeGameHUD.zIndex(10)
                
                if !vm.isContentPlaced {
                    VStack {
                        Spacer()
                        Text(vm.isSurfaceDetected ? AppStrings.tapToPlace : AppStrings.scanSurface)
                            .font(.headline)
                            .foregroundStyle(vm.isSurfaceDetected ? Color.green : Color.white)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                            .padding(.bottom, 120)
                            .animation(.easeInOut, value: vm.isSurfaceDetected)
                    }
                }
                
                if vm.showPlacementWarning {
                    VStack {
                        Spacer()
                        Text(AppStrings.placeWarning)
                            .font(.body.bold())
                            .foregroundStyle(.white)
                            .padding()
                            .background(Color.red.opacity(0.9))
                            .clipShape(Capsule())
                            .shadow(radius: 5)
                            .padding(.bottom, 220)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }.zIndex(30)
                }
            }
        }
    }
    
    var activeGameHUD: some View {
        VStack {
            
            HStack {
                Button(action: {
                    vm.exitAR()
                    mode = 0
                }) {
                    Image(systemName: "house.fill")
                        .font(.title2)
                        .foregroundStyle(.black)
                        .frame(width: 50, height: 50)
                        .background(Circle().fill(Color.white))
                        .shadow(radius: 4)
                }
                .padding()
                
                Spacer()
                
                
                if !vm.isEditMode {
                    Button(action: { vm.exitAR() }) {
                        Image(systemName: AppIcons.close)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.black)
                            .frame(width: 50, height: 50)
                            .background(Circle().fill(Color.yellow))
                            .shadow(radius: 4)
                    }
                    .padding()
                }
            }
            
            Spacer()
            
            
            if vm.isEditMode {
                
                VStack(spacing: 15) {
                    Text(vm.selectedPanelName != nil ? "Editing: \(vm.selectedPanelName!)" : "Long Press a Panel to Edit")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.vertical, 5)
                        .padding(.horizontal)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Capsule())
                    
                    if vm.isPanelSelected {
                        VStack(spacing: 10) {
                            
                            HStack {
                                Text("Height")
                                Slider(value: $vm.editHeight, in: -0.5...0.5)
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .padding(.horizontal, 40)
                    }
                    
                    Button("Done") {
                        withAnimation {
                            vm.isEditMode = false
                            vm.selectedPanelName = nil
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .padding(.bottom)
                }
                .frame(maxWidth: .infinity)
                .background(Color.black.opacity(0.3))
            } else {
                VStack {
                    if vm.isTimerRunning, let end = vm.timerEndDate {
                        TimelineView(.periodic(from: .now, by: 1.0)) { context in
                            let remaining = end.timeIntervalSinceNow
                            if remaining > 0 {
                                HStack {
                                    Image(systemName: "timer")
                                    Text(DateComponentsFormatter().string(from: remaining) ?? "00:00")
                                        .font(.system(size: 40, weight: .bold).monospacedDigit())
                                }
                                .padding()
                                .background(.ultraThinMaterial)
                                .clipShape(Capsule())
                                .padding(.bottom, 10)
                            } else {
                                Text("TIMER DONE!")
                                    .font(.largeTitle.bold())
                                    .foregroundStyle(.red)
                                    .padding()
                                    .background(.white)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    
                    HStack(spacing: 20) {
                        
                        Button(action: {
                            if vm.isTimerRunning { vm.pauseTimer() } else { vm.resumeTimer() }
                        }) {
                            Image(systemName: vm.isTimerRunning ? "pause.fill" : "play.fill")
                                .font(.largeTitle)
                                .foregroundStyle(.white)
                                .frame(width: 70, height: 70)
                                .background(Circle().fill(vm.isTimerRunning ? Color.red : Color.green))
                                .shadow(radius: 4)
                        }
                        
                        Button(action: { vm.showTimerPicker = true }) {
                            VStack(spacing: 2) {
                                Image(systemName: "timer")
                                Text("TIMER").font(.caption2.bold())
                            }
                            .frame(width: 70, height: 60)
                            .background(Capsule().fill(Color.white))
                            .foregroundStyle(.black)
                        }
                        
                        Divider().frame(height: 40)
                        
                        Button(action: {
                            withAnimation { vm.isEditMode = true }
                        }) {
                            VStack(spacing: 2) {
                                Image(systemName: "slider.horizontal.3")
                                Text("EDIT").font(.caption2.bold())
                            }
                            .frame(width: 70, height: 60)
                            .background(Capsule().fill(Color.white))
                            .foregroundStyle(.black)
                        }
                        
                        Button(action: {
                            NotificationCenter.default.post(name: NSNotification.Name("ResetARSession"), object: nil)
                        }) {
                            VStack(spacing: 2) {
                                Image(systemName: "arrow.counterclockwise")
                                Text("RESET").font(.caption2.bold())
                            }
                            .frame(width: 70, height: 60)
                            .background(Capsule().fill(Color.white))
                            .foregroundStyle(.red)
                        }
                    }
                }
                .padding(.bottom, 20)
                .padding(.horizontal)
            }
        }
        .sheet(isPresented: $vm.showTimerPicker) {
            VStack(spacing: 20) {
                Text("Set Timer").font(.headline).padding(.top)
                Picker("Minutes", selection: $vm.selectedTimeIndex) {
                    ForEach(1...60, id: \.self) { i in Text("\(i) min").tag(i) }
                }
                .pickerStyle(.wheel)
                Button("START TIMER") {
                    vm.startManualTimer(minutes: Double(vm.selectedTimeIndex))
                    vm.showTimerPicker = false
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(.green)
                .padding()
            }
            .presentationDetents([.medium])
        }
    }
}

