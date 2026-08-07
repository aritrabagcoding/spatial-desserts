import SwiftUI
import SwiftData

struct CollectionView: View {
    @Binding var mode: Int
    @Binding var selectedRecipe: RecipeModel?
    @Query var allRecipes: [RecipeModel]
    
    @State private var viewCategory: CollectionCategory? = nil
    @State private var itemInDetail: RecipeModel? = nil
    
    enum CollectionCategory: String, CaseIterable {
        case liked = "Recipes I liked"
        case notType = "Recipes I didn't like"
        case completed = "Puzzles completed"
        
        var icon: String {
            switch self {
            case .liked: return "hand.thumbsup.fill"
            case .notType: return "hand.thumbsdown.fill"
            case .completed: return "checkmark.seal.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .liked: return Pal.cGold
            case .notType: return Pal.cRedTop
            case .completed: return Pal.cCyan
            }
        }
    }
    
    var body: some View {
        ZStack {
            
            Pal.cTabTop.ignoresSafeArea()
            
            if let item = itemInDetail {
                detailView(item: item)
                    .transition(.opacity)
            } else if let cat = viewCategory {
                listView(category: cat)
                    .transition(.move(edge: .trailing))
            } else {
                mainMenuView
                    .transition(.move(edge: .leading))
            }
        }
        .animation(.easeInOut, value: viewCategory)
        .animation(.easeInOut, value: itemInDetail)
    }
    
    
    var mainMenuView: some View {
        VStack(spacing: 30) {
            
            HStack {
                Button(action: { mode = 0 }) {
                    HStack(spacing: 5) {
                        Image(systemName: "chevron.left")
                        Text("Home")
                    }
                    .font(.headline)
                    .foregroundStyle(Pal.cBrnTxt)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 15)
                    .background(Capsule().fill(Color.white.opacity(0.8)))
                }
                Spacer()
                Text("COLLECTIONS")
                    .font(.largeTitle).bold()
                    .foregroundStyle(Pal.cBrnTxt)
                Spacer()
                Color.clear.frame(width: 80, height: 1)
            }
            .padding()
            
            Spacer()
            
            HStack(spacing: 20) {
                categoryButton(cat: .liked)
                categoryButton(cat: .notType)
                categoryButton(cat: .completed)
            }
            .padding()
            
            Spacer()
        }
    }
    
    func categoryButton(cat: CollectionCategory) -> some View {
        Button(action: { viewCategory = cat }) {
            VStack(spacing: 20) {
                Circle()
                    .fill(cat.color.opacity(0.2))
                    .frame(width: 100, height: 100)
                    .overlay {
                        Image(systemName: cat.icon)
                            .font(.system(size: 40))
                            .foregroundStyle(cat.color)
                    }
                
                Text(cat.rawValue)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Pal.cBrnTxt)
            }
            .frame(width: 200, height: 240)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
        }
    }
    
    func listView(category: CollectionCategory) -> some View {
        let filtered = getRecipes(for: category)
        
        return VStack {
            HStack {
                Button(action: { viewCategory = nil }) {
                    HStack(spacing: 5) {
                        Image(systemName: "chevron.left")
                        Text("Collections")
                    }
                    .font(.headline)
                    .foregroundStyle(Pal.cBrnTxt)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 15)
                    .background(Capsule().fill(Color.white.opacity(0.8)))
                }
                Spacer()
            }
            .padding()
            
            
            if filtered.isEmpty {
                
                Spacer()
                
                VStack {
                    Image(systemName: "tray")
                        .font(.system(size: 50))
                        .foregroundStyle(.gray.opacity(0.5))
                    Text("No recipes here yet.")
                        .font(.headline)
                        .foregroundStyle(.gray)
                }
                
                Spacer()
            } else {
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 180))]) {
                        ForEach(filtered) { item in
                            Button(action: { itemInDetail = item }) {
                                VStack(alignment: .leading) {
                                    Image.safe(item.imageName)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 120)
                                        .clipped()
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    
                                    Text(item.name)
                                        .font(.headline)
                                        .foregroundStyle(Pal.cBrnTxt)
                                        .padding(.horizontal, 5)
                                    
                                    if !item.emojiMood.isEmpty {
                                        Text("Rating: \(item.emojiMood)")
                                            .font(.caption)
                                            .foregroundStyle(.gray)
                                            .padding(.horizontal, 5)
                                            .padding(.bottom, 10)
                                    }
                                }
                                .padding(5)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .shadow(radius: 2)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
    
    func detailView(item: RecipeModel) -> some View {
        ZStack {
            Color.black.opacity(0.8).ignoresSafeArea()
            
            VStack(spacing: 20) {
                HStack {
                    Spacer()
                    Button(action: { itemInDetail = nil }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(.white)
                    }
                }
                .padding()
                
                Image.safe(item.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 350)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(radius: 10)
                
                Text(item.name)
                    .font(.largeTitle).bold()
                    .foregroundStyle(Pal.cGold)
                
                if !item.userFeedback.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("YOUR THOUGHTS:")
                            .font(.caption).bold().foregroundStyle(.gray)
                        Text("\"\(item.userFeedback)\"")
                            .font(.body).italic()
                            .foregroundStyle(.white)
                        Divider().background(.gray)
                        HStack {
                            Text("Mood:")
                                .foregroundStyle(.gray)
                            Text(item.emojiMood)
                                .font(.title2)
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }
                
                Spacer()
                
                HStack(spacing: 20) {
                    Button(action: {
                        selectedRecipe = item
                        mode = 3 
                    }) {
                        Label("Cook in AR", systemImage: "cube.transparent")
                            .font(.headline)
                            .foregroundStyle(.black)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Pal.cGold)
                            .clipShape(Capsule())
                    }
                    
                    Button(action: {
                        removeFromCollection(item: item)
                        itemInDetail = nil
                    }) {
                        Label("Remove", systemImage: "trash")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.8))
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
    }
    func getRecipes(for cat: CollectionCategory) -> [RecipeModel] {
        switch cat {
        case .liked:
            return allRecipes.filter { $0.status == 2 && ($0.emojiMood == "🤩" || $0.emojiMood == "😊") }
        case .notType:
            return allRecipes.filter { $0.status == 2 && ($0.emojiMood == "😐" || $0.emojiMood == "😢") }
        case .completed:
            return allRecipes.filter { $0.status == 2 }
        }
    }
    
    func removeFromCollection(item: RecipeModel) {
        guard let cat = viewCategory else { return }
        
        withAnimation {
            switch cat {
            case .liked, .notType:
                item.userFeedback = ""
                item.emojiMood = ""
            case .completed:
                item.status = 0
                item.puzzleStateJSON = ""
                item.userFeedback = ""
                item.emojiMood = ""
            }
        }
    }
}

