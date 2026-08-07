import SwiftUI
import SwiftData

struct GalleryView: View {
    @Binding var mode: Int
    @Binding var selItem: RecipeModel?
    @Query var items: [RecipeModel]
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                
                HStack {
                    Button(action: { mode = 0 }) {
                        HStack(spacing: 5) {
                            Image(systemName: "chevron.left")
                            Text(AppStrings.back)
                        }
                        .font(.headline)
                        .foregroundStyle(Pal.cBrnTxt)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 15)
                        .background(Capsule().fill(Color.white.opacity(0.8)))
                    }
                    
                    Spacer()
                    Text("Select Recipe")
                        .font(.headline)
                        .foregroundStyle(Pal.cBrnTxt)
                    Spacer()
                    Color.clear.frame(width: 80, height: 1)
                }
                .padding()
                .background(Pal.cTabTop.opacity(0.9))
                
                
                ScrollView {
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: geo.size.width * 0.3), spacing: 20)], spacing: 20) {
                        ForEach(items) { item in
                            Button(action: { selItem = item; mode = 3 }) {
                                ZStack(alignment: .topTrailing) {
                                    VStack {
                                        Image.safe(item.imageName)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: geo.size.width * 0.2)
                                            .padding(5)
                                        
                                        Text(item.name).foregroundStyle(Pal.cBrnTxt).bold()
                                        
                                        
                                        if item.status == 2 {
                                            Text("SERVED").font(.caption).bold().foregroundStyle(Color.green)
                                        } else if item.status == 1 {
                                            Text("IN PROGRESS").font(.caption).bold().foregroundStyle(Color.red)
                                        } else {
                                            Text("NOT STARTED").font(.caption).foregroundStyle(.gray)
                                        }
                                    }
                                    .frame(height: geo.size.width * 0.35).frame(maxWidth: .infinity)
                                    .background { Color.white }
                                    
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 4)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(item.status == 2 ? Color.green : Color.clear, lineWidth: 2)
                                    }
                                }
                            }
                            .contextMenu {
                                if item.status == 1 {
                                    Button(role: .destructive) {
                                        withAnimation {
                                            item.status = 0
                                            item.puzzleStateJSON = ""
                                        }
                                    } label: {
                                        Label("Reset Progress", systemImage: "arrow.counterclockwise")
                                    }
                                }
                            }
                        }
                    }.padding()
                }
            }
            .background { Pal.cTabTop }
        }
    }
}

