import SwiftUI

struct EditContactView: View {
    @StateObject var viewModel: EditContactViewModel

    init(contact: Contact) {
        let model = EditContactViewModel(contact: contact)
        _viewModel = StateObject(wrappedValue: model)
    }

    // MARK: - Main View
    var body: some View {
        GeometryReader { reader in
            ScrollView {
                Spacer().frame(height: 50)

                personalInfoSection()
                    .padding(.top, |20)

                contactInfoSection()

                addressSection()
            }
            .frame(height: reader.size.height)
        }
    }

    // MARK: - Components
    @ViewBuilder
    private func personalInfoSection() -> some View {
        VStack(spacing: 16) {
            HStack(spacing: -17) {
                HexagonTextField(text: firstName, promt: "First Name")
                HexagonTextField(text: lastName, promt: "Last Name")
            }
            HexagonTextField(text: company, promt: "Company")
        }
    }

    @ViewBuilder
    private func sectionHeader(text: String, action: (() -> Void)? = nil) -> some View {
        HStack {
            Text(text)
                .font(Font.montserat(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            if let action {
                Button(action: action) {
                    Text("Add")
                        .font(Font.montserat(size: 14, weight: .medium))
                        .foregroundStyle(.appGreen)
                }
            }
        }
        .padding(.horizontal, <->16)
        .padding(.top, 32)
        .padding(.bottom, 18)
    }

    @ViewBuilder
    private func contactInfoSection() -> some View {
        VStack(spacing: 0) {
            sectionHeader(
                text: "Contact Info",
                action: {
                    viewModel.handle(.addPhoneNumber(.init(id: UUID().uuidString, label: LabeledValueLabelType.mobile.value, value: "")))
                }
            )

            VStack(spacing: 14) {
                ForEach(viewModel.state.contactInfo) { info in
                    let text = Binding(
                        get: { info.value },
                        set: { viewModel.handle(.editContactMetod(id: info.id, newValue: .init(id: info.id, label: info.label, value: $0))) }
                    )

                    ContactInfoTextField(
                        text: text,
                        promt: "",
                        fieldType: info.labelType,
                        deleteAction: { viewModel.handle(.deleteContactMetod(id: info.id, type: info.labelType)) },
                        onTypeChange: { viewModel.handle(.editContactMetod(id: info.id, newValue: .init(id: info.id, label: $0.value, value: info.value))) }
                    )
                }
            }
        }
    }

    @ViewBuilder
    private func addressSection() -> some View {
        VStack(spacing: 0) {
            sectionHeader(
                text: "Address",
                action: {
                    viewModel.handle(.addPostalAddress(.init(id: UUID().uuidString, label: "", value: "")))
                }
            )

            VStack(spacing: 14) {
                ForEach(viewModel.state.postalAddresses) { address in
                    let text = Binding(
                        get: { address.value },
                        set: { viewModel.handle(.editPostalAddress(id: address.id, newValue: .init(id: address.id, label: address.label, value: $0))) }
                    )

                    HexagonTextField(
                        text: text,
                        promt: "Address",
                        deleteAction: { viewModel.handle(.deletePostalAddress(id: address.id)) })
                }
            }
        }
    }

    @ViewBuilder
    private func birthdateSection() -> some View {
        VStack(spacing: 14) {
            //            sectionHeader(text: "Birthdate", action: model.addBirthdate)
            //
            //            ForEach(model.birthdates) { birthdate in
            //                let date = Binding(get: { birthdate.date },
            //                                   set: { date in
            //                    model.setBirthdate(birthdate, to: date)
            //                })
            //                HexagonDatePicker(
            //                    date: date
            //                )
            //            }
        }
    }

    @ViewBuilder
    private func socialMediaSection() -> some View {
        VStack(spacing: 14) {
            sectionHeader(text: "Social Media")

            //            ForEach(model.socialMedia) { media in
            //                let text = Binding(get: { media.userHandle },
            //                                   set: { handle in
            //                    model.setSocialMediaHandle(of: media, to: handle)
            //                })
            //                SocialMediaTextField(
            //                    text: text,
            //                    promt: media.mediaType.title,
            //                    socialMedia: media.mediaType
            //                )
            //            }
        }
    }

    // MARK: - Bindings
    private var firstName: Binding<String> {
        Binding(
            get: { viewModel.state.givenName ?? "" },
            set: { viewModel.handle(.editGivenName($0))
            }
        )
    }

    private var lastName: Binding<String> {
        Binding(
            get: { viewModel.state.familyName ?? "" },
            set: { viewModel.handle(.editFamilyname($0))
            }
        )
    }

    private var company: Binding<String> {
        Binding(
            get: { viewModel.state.organizationName ?? "" },
            set: { viewModel.handle(.editOrganizationName($0))
            }
        )
    }
}

#Preview {
    NavigationStack {
        EditContactView(contact: Contact.testContact)
            .background(Color.appBackground)
    }
}

extension Contact {
    static var testContact: Contact = .init(
        id: UUID().uuidString,
        givenName: "Mark",
        middleName: "A",
        familyName: "Reed",
        organizationName: "TestCo",
        phoneNumbers: [],
        emailAddresses: [],
        postalAddresses: [],
        urlAddresses: [],
        socialProfiles: [],
        instantMessageAddresses: [],
        birthday: nil,
        imageData: nil,
        imageDataAvailable: false,
        isFavorite: false
    )
}
