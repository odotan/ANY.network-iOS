import SwiftUI

struct SearchView: View {
    @StateObject var viewModel: SearchViewModel
        
    var body: some View {
        VStack {
            List(viewModel.state.list) { contact in
                Button {
                    viewModel.handle(.goToDetails(contact: contact))
                } label: {
                    ContactCell(contact: contact)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
        }
        .padding(.top, 40) // 
        .searchTextField(text: searchTerm) {
            print("Action pressed")
        }
        .backButton {
            viewModel.handle(.goBack)
        }
        .toolbar(.hidden)
        .listRowSpacing(-10)
        .listStyle(.plain)
        .background(.appBackground)
        .task {
            viewModel.handle(.getAll)
        }
    }
    
    private var searchTerm: Binding<String> {
        return Binding(
            get: { viewModel.state.searchTerm },
            set: { viewModel.handle(.updateSearchTerm($0)) }
        )
    }
}
