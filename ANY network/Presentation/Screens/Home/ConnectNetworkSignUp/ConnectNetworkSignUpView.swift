import SwiftUI

struct ConnectNetworkSignUpView: View {
    @StateObject var viewModel: ConnectNetworkSignUpViewModel
    let sms = SMSNetworkAuthentication()
    
    var title: String {
        viewModel.state.networkItem.title
    }
    
    private var pillToolbarItems: [PillToolbarItem] {
        var items: [PillToolbarItem] = [
            .init(icon: .back, position: .leading) {
                self.viewModel.handle(.goBack)
            }
        ]
        
        if self.viewModel.state.continueButtonIsVisible {
            items.append(.init(icon: .customText("Connect"), position: .middle) {
                self.viewModel.handle(.sendRequest)
            })
        }
        return items
    }

    var body: some View {
        VStack(spacing: 0) {
            NetworkLogoHexView(item: viewModel.state.networkItem)
                .padding(.top, 130)
            
            Text(title)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.3)
                .lineLimit(2)
                .font(.montserat(size: 24, weight: .bold))
                .foregroundColor(.white)
                .frame(width: <->300)
                .padding(.top, |26)
            
            Text("Lorem ipsum dolor sit amet, consetet sadipscing elitr, sed diam nonumy eirmod")
                .font(.montserat(size: 12, weight: .regular))
                .multilineTextAlignment(.center)
                .foregroundColor(.white.opacity(0.7))
                .padding(.horizontal, <->16)
                .padding(.top, |14)
            
            if viewModel.state.showCodeField {
                HexagonTextField(text: code, promt: "Code", keyboardType: .numberPad)
                    .padding(.top, |36)
            }
            
            if viewModel.state.showInputField {
                HexagonTextField(text: inputValue, promt: "Input Value", keyboardType: viewModel.state.inputValueKeyboardType)
                    .padding(.top, |36)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .pillToolbar(items: pillToolbarItems)
        .alert(isPresented: errorPresented, error: viewModel.state.error, actions: {
            Button("OK") {}
        })
        .onOpenURL(perform: { url in
            viewModel.emailValidation(url: url)
        })
        .toolbar(.hidden)
        .background(.appBackground)
    }
    
    private var code: Binding<String> {
        .init(
            get: { viewModel.state.code },
            set: { viewModel.handle(.updateCode($0)) }
        )
    }
    
    private var inputValue: Binding<String> {
        .init(
            get: { viewModel.state.inputValue },
            set: { viewModel.handle(.updateInputField($0)) }
        )
    }
    
    private var errorPresented: Binding<Bool> {
        .init(
            get: { viewModel.state.error != nil },
            set: { if !$0 { viewModel.handle(.hideError) } }
        )
    }
}
