import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel
    
    private let minOffset: CGFloat = 0
    private let maxOffset: CGFloat = 500

    @State private var screenSize: CGSize = .zero
    @State var offset: CGFloat = 391
    
    @State private var selectedSection: String?

    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            SearchBarView(
                term: searchTerm,
                searchPressed: {
                    viewModel.handle(.searchPressed)
                }, 
                filterPressed: {
                    viewModel.handle(.filterPressed)
                }
            )
            .padding(.horizontal, <->16)
            .padding(.top, |24)
            
            if !viewModel.state.showSearch {
                favourites
                    .frame(height: offset)
                
                HomeRecentView { dragGesture }
            } else {
                searchList
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onSizeChange(perform: { size in
            screenSize = size
        })
        .background(Color.appBackground.ignoresSafeArea())
//        .onAppear {
//            viewModel.handle(.getAllContacts)
//        }
    }
    
    @ViewBuilder
    var header: some View {
        HStack(spacing: 0) {
            Spacer()
            
            Image(.flowerNav)
                .resizable()
                .frame(width: <->20.11, height: |19.5)
            
            Spacer()
        }
        .frame(height: |40)
    }
    
    @ViewBuilder
    var favourites: some View {
        Color.clear
            .overlay(alignment: .topLeading) {
                HStack {
                    Text("Favorites")
                        .font(Font.custom(Font.montseratMedium, size: |18))
                        .foregroundColor(.white)
                        .padding(.horizontal, <->16)
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.handle(.addFavoritePressed)
                    }, label: {
                        Text("Add")
                            .font(.custom(Font.montseratMedium, size: |18))
                            .lineSpacing(4)
                            .foregroundColor(.appGreen)
                    })
                    .padding(.trailing, <->16)
                }
            }
            .padding(.top, |19)
    }
    
    @ViewBuilder
    var searchList: some View {
        List(viewModel.state.searched!) { contact in
            ContactCell(contact: contact)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
        }
        .listRowSpacing(-10)
        .listStyle(.plain)
        .background(.appBackground)
    }
    
    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { drag in
                var new = offset
                new += drag.translation.height
                
                if new < minOffset {
                    offset = minOffset
                } else if new > maxOffset {
                    offset = maxOffset
                } else {
                    offset = new
                }
            }
    }
    
    private var searchTerm: Binding<String> {
        return Binding(
            get: { viewModel.state.searchTerm },
            set: { viewModel.handle(.searchUpdated(term: $0)) }
        )
    }
}

#Preview {
    HomeView(viewModel: 
            .init(
                coordinator: MainCoordinator(),
                getAllContactsUseCase:
                    GetAllContactsUseCase(repository: ContactsService()),
                searchUseCase: SearchNameUseCase(repository: ContactsService())
            )
    )
}
