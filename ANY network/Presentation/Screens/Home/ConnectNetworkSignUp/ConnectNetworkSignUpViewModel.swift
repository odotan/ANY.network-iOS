import Foundation

final class ConnectNetworkSignUpViewModel: ViewModel {
    @Published private(set) var state: State
    private let coordinator: MainCoordinatorProtocol
    private let smsAuthenticatorUseCase: SMSSendCodeUseCase
    private let facebookLoginUseCase: FacebookLoginUseCase
    private let telegramLoginUseCase: TelegramLoginUseCase
    private let emailLoginUseCase: EmailLoginUseCase
    
    init(
        networkItem: NetworkItem,
        contact: Contact,
        coordinator: MainCoordinatorProtocol,
        smsAuthenticatorUseCase: SMSSendCodeUseCase,
        facebookLoginUseCase: FacebookLoginUseCase,
        telegramLoginUseCase: TelegramLoginUseCase,
        emailLoginUseCase: EmailLoginUseCase
    ) {
        self.state = State(networkItem: networkItem, contact: contact)
        self.coordinator = coordinator
        self.smsAuthenticatorUseCase = smsAuthenticatorUseCase
        self.facebookLoginUseCase = facebookLoginUseCase
        self.telegramLoginUseCase = telegramLoginUseCase
        self.emailLoginUseCase = emailLoginUseCase
        setup()
    }
    
    func handle(_ event: Event) {
        switch event {
        case .goBack:
            coordinator.pop()
        case .showConfirmation:
            coordinator.showConnectConfirmation(networkItem: state.networkItem)
        case .sendRequest:
            Task {
                await sendRequest()
            }
        case .updateCode(let code):
            state.code = code
        case .updateInputField(let value):
            state.inputValue = value
        case .hideError:
            state.error = nil
        }
    }
    
    private func setup() {
        switch state.networkItem {
        case .phone, .telegram:
            state.showInputField = true
            
            let phone = state.contact.phoneNumbers.first?.value ?? ""
            state.inputValueKeyboardType = .phonePad
            handle(.updateInputField(phone))
        case .email:
            state.showInputField = true
            
            let email = state.contact.emailAddresses.first?.value ?? ""
            state.inputValueKeyboardType = .emailAddress
            handle(.updateInputField(email))
        default: break
        }
    }
    
    private func sendRequest() async {
        do {
            switch state.networkItem {
            case .phone:
                if !state.code.isEmpty {
                    let user = try await smsAuthenticatorUseCase.verifyCode(state.code)
                    print("!!! User", user)
                    
                    handle(.showConfirmation)
                } else {
                    let authId = try await smsAuthenticatorUseCase.sendCode(to: state.inputValue)
                    print("AUTHID", authId)
                    state.showCodeField = true
                    state.showInputField = false
                }
            case .facebook:
                let token = try await facebookLoginUseCase.signIn()
                handle(.showConfirmation)
            case .telegram:
                if !state.code.isEmpty {
                    try await telegramLoginUseCase.verifyCode(state.code)
                    
                    handle(.showConfirmation)
                } else {
                    try await telegramLoginUseCase.sendCode(to: state.inputValue)
                    state.showCodeField = true
                    state.showInputField = false
                }
            case .email:
                try await emailLoginUseCase.sendSignInLink(to: state.inputValue)
                state.continueButtonIsVisible = false
                state.showInputField = false
            default:
                print("")
            }
        } catch {
            let wrappedError = EquatableError(error: error)
            state.error = wrappedError
            
            print("Error:", wrappedError.localizedDescription, "\n", (error as? NSError)?.userInfo)
        }
    }
    
    func emailValidation(url: URL) {
        Task {
            do {
                print("App opened with URL: \(url)")
                var paramDict = [String: String]()

                if let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
                   let queryItems = components.queryItems {
                    for item in queryItems {
                        paramDict[item.name] = item.value ?? ""
                    }
                }
                
                guard let link = paramDict["link"] else {
                    throw EmailError.missingLink
                }

                try await emailLoginUseCase.verifyEmail(link)
                handle(.showConfirmation)
            } catch {
                let wrappedError = EquatableError(error: error)
                state.error = wrappedError
                
                print("Error:", wrappedError.localizedDescription, "\n", (error as? NSError)?.userInfo)
            }
        }
    }
}
