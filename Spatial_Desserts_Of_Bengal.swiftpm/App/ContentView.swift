import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var vm = ContentViewModel()
    @Query var items: [RecipeModel]
    
    var body: some View {
        ZStack {
            if vm.mode == 0 {
                HomeView(mode: $vm.mode)
            }
            else if vm.mode == 1 {
                GalleryView(mode: $vm.mode, selItem: $vm.selectedRecipe)
            }
            else if vm.mode == 3 {
                if let item = vm.selectedRecipe ?? items.first {
                    GameView(mode: $vm.mode, currentRecipe: item)
                }
            }
            else if vm.mode == 4 {
                
                CollectionView(mode: $vm.mode, selectedRecipe: $vm.selectedRecipe)
            }
        }
        .animation(.easeInOut, value: vm.mode)
    }
}

