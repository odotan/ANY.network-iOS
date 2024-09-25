import SwiftUI

struct SearchView: View {
    @StateObject var viewModel: SearchViewModel
    @Environment(\.dismiss) var dismiss
        
    var body: some View {
        VStack {
            if !viewModel.state.list.isEmpty {
                searchedList
            } else if !viewModel.state.searchTerm.isEmpty {
                addContact
            } else {
                Spacer()
            }
        }
        .padding(.top, 40) // 
        .searchTextField(text: searchTerm) {
            viewModel.handle(.addContact)
        }
        .overlay(alignment: .topLeading) {
            Button(action: {
                dismiss()
            }, label: {
                Image(.backBtn)
                    .rotationEffect(.degrees(-90))
                    .padding(.top, |8)
                    .padding(.bottom, |5)
                    .padding(.horizontal)
            })
        }
        .overlay(alignment: .top) {
            Text("Search")
                .font(.montserat(size: 20, weight: .bold))
                .foregroundColor(.white)
        }
        .toolbar(.hidden)
        .listRowSpacing(-10)
        .listStyle(.plain)
        .background(.appBackground)
        .task {
            viewModel.handle(.getAll)
        }
    }
    
    @ViewBuilder
    var addContact: some View {
        VStack(spacing: 16) {
            Text("\"\(viewModel.state.searchTerm)\"")
                .foregroundColor(.white)
                .font(.montserat(size: 20, weight: .semibold))
            
            Text("There is nothing to show on your contact list")
                .foregroundColor(.white.opacity(0.7))
                .font(.montserat(size: 18))
                .multilineTextAlignment(.center)
            
            Button {
                viewModel.handle(.addContact)
            } label: {
                HStack(spacing: 8) {
                    Rectangle()
                        .frame(width: 15, height: 1.5)
                        .foregroundColor(.appGreen)
                        .frame(height: 15)
                        .overlay {
                            Rectangle()
                                .frame(width: 1.5, height: 15)
                                .foregroundColor(.appGreen)
                        }
                    Text("Create New Contact")
                        .foregroundColor(.appGreen)
                        .font(.montserat(size: 18))
                }
            }.buttonStyle(.plain)
        }
        .frame(maxHeight: .infinity)
    }
    
    @ViewBuilder
    var searchedList: some View {
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
    
    private var searchTerm: Binding<String> {
        return Binding(
            get: { viewModel.state.searchTerm },
            set: { viewModel.handle(.updateSearchTerm($0)) }
        )
    }
}
