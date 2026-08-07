import SwiftUI
import SwiftData

@main
struct ChefApp: App {
    var modelContainer: ModelContainer?
    
    init() {
        do {
            modelContainer = try ModelContainer(for: RecipeModel.self)
        } catch {
            print("CRITICAL DB ERROR: \(error)")
            modelContainer = nil
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if let container = modelContainer {
                ContentView()
                    .onAppear {
                        AuMgr.shared.playBGM()
                        Task { @MainActor in
                            await seed(ctx: container.mainContext)
                        }
                    }
                    .modelContainer(container)
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.red)
                    Text("System Maintenance")
                        .font(.largeTitle).bold()
                    Text("The Kitchen Database could not be loaded.\nPlease reinstall the app.")
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
        }
    }
    
    @MainActor
    func seed(ctx: ModelContext) async {
        do {
            let count = try ctx.fetchCount(FetchDescriptor<RecipeModel>())
            if count == 0 {
                let items = await DataSeeder.gen()
                for i in items { ctx.insert(i) }
                try? ctx.save()
            }
        } catch {
            print("Seeding Error: \(error)")
        }
    }
}

