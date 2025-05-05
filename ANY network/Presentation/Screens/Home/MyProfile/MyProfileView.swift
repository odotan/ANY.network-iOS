import SwiftUI

struct MyProfileView: View {
    @StateObject var viewModel: MyProfileViewModel

    var body: some View {
        VStack {
            Text("Select Your Contact Card")
                .font(.montserat(size: 20, weight: .bold))
                .foregroundColor(.white)
                .padding(.bottom, 24)
            
            if !viewModel.state.list.isEmpty {
                searchedList
                    
            } else {
                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
        .interactiveDismissDisabled()
        .padding(.top, 40)
        .backButton {
            viewModel.handle(.goBack)
            viewModel.handle(.setDismiss)
        }
        .searchTextField(text: searchTerm, isSearching: isSearching)
        .toolbar(.hidden)
        .listRowSpacing(-10)
        .listStyle(.plain)
        .background(.appBackground)
        .alert("Is your name: \(viewModel.state.selected?.fullName ?? "")", isPresented: isAlertPresented, actions: {
            Button("Yes") {
                viewModel.handle(.setContactConfirmation)
            }

            Button("No") {
                viewModel.handle(.select(nil))
            }
        })
        .task {
            viewModel.handle(.getAll)
        }
    }

    @ViewBuilder
    var searchedList: some View {
        List(viewModel.state.list) { contact in
            Button {
                viewModel.handle(.select(contact))
            } label: {
                ContactCell(contact: contact, onInteraction: { _ in })
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
    }
    
    private var searchTerm: Binding<String> {
        return Binding(
            get: { viewModel.state.searchTerm },
            set: { viewModel.handle(.updateSearchTerm($0)) }
        )
    }
    
    private var isSearching: Binding<Bool> {
        .init(
            get: { viewModel.state.isSearching },
            set: { viewModel.handle(.setIsSearching($0)) }
        )
    }
    
    private var isAlertPresented: Binding<Bool> {
        .init(
            get: { viewModel.state.isAlertPresented },
            set: { viewModel.handle(.setIsAlertPresented($0)) }
        )
    }
}
