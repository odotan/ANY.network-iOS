import SwiftUI

struct ContactsPermissionView: View {
    @StateObject var viewModel: ContactsPermissionViewModel
    
    var body: some View {
        Button(action: {
            viewModel.handle(.allow)
        }, label: {
            Text("Get access")
        })
    }
    
    private enum Constants {
        enum Strings {
            static let title = "Your Contacts -\nSupercharged!"
            static let subText1 = """
                ANY network needs contact permissions to
                give you a new phone-book experience.
            """
            static let subText2 = """
                It will still work without contact permissions, but
                it won’t show your contact list.
            """
            static let subText3 = """
                Even if you allow, your contacts will not be
                shared with ANY servers without your consent
                
                You can change this at any time under Settings
            """
            static let allowButton = "Allow Contact Permissions"
            static let skipButton = "Skip"
        }
    }
}

#Preview {
    ContactsPermissionView(viewModel: .init(coordinator: OnboardingCoordinator(showMainFlowHandler: {}), getRequestAccessUseCase: .init(repository: ContactsRepositoryImplementation(realmDataSource: RealmContactsDataSource(), nativeDataSource: NativeContactsDataSource()))))
}
