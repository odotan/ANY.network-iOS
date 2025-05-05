import SwiftUI

struct EditContactView: View {
    @ObservedObject var viewModel: EditContactViewModel

    //    init(viewModel: EditContactViewModel) {
    //        _viewModel = StateObject(wrappedValue: viewModel)
    //    }

    // MARK: - Main View
    var body: some View {
        VStack {
            Spacer().frame(height: 50)
            
            personalInfoSection()
                .padding(.top, |20)
            
            contactInfoSection()
            
            addressSection()
            //                    .padding(.bottom, 30)
            
            addButton()
                .padding(.vertical, 20)

            Spacer()
        }
        .onAppear { viewModel.handle(.getSections) }
    }

    // MARK: - Components
    @ViewBuilder
    private func personalInfoSection() -> some View {
        VStack(spacing: 16) {
            HStack(spacing: -17) {
                HexagonTextField(text: firstName, promt: "First Name")
                HexagonTextField(text: lastName, promt: "Last Name")
            }

            if viewModel.state.presentedSections.contains(.company) {
                HexagonTextField(text: company, promt: "Company") {
                    withAnimation {
                        viewModel.handle(.showSection(.company, false))
                    }
                }
                    .id("company")
            }
        }
    }

    @ViewBuilder
    private func addSectionMenu() -> some View {
        Menu {
            VStack {
                submenu(title: Constants.Strings.phoneNumber, values: PhoneNumberType.allCases) { type in
                    viewModel.handle(.addPhoneNumber(.init(id: UUID().uuidString, label: type.label, value: "", infoType: type)))
                }

                submenu(title: Constants.Strings.emailAddress, values: EmailAddressType.allCases) { type in
                    viewModel.handle(.addEmailAddress(.init(id: UUID().uuidString, label: type.label, value: "", infoType: type)))
                }

                othersMenu()
            }
        } label: {
            Text(Constants.Strings.add)
                .font(Font.montserat(size: 14, weight: .medium))
                .foregroundStyle(.appGreen)
                .frame(width: <->80, height: 40)
        }
    }

    @ViewBuilder
    private func submenu<T: ContactInfoType>(title: String, values: [T], action: @escaping (T) -> Void) -> some View {
        Menu {
            ForEach(values, id: \.self) { type in
                Button(action: { withAnimation { action(type) } } ) {
                    Text(type.title)
                        .font(Font.montserat(size: 14, weight: .medium))
                        .minimumScaleFactor(0.7)
                }
            }
        } label: {
            Text(title)
                .font(Font.montserat(size: 14, weight: .medium))
                .minimumScaleFactor(0.7)
        }
    }

    @ViewBuilder
    private func othersMenu() -> some View {
        Menu {
            if !viewModel.state.presentedSections.contains(.company) {
                Button(action: {
                    withAnimation {
                        viewModel.handle(.showSection(.company, true))
                    }
                }) {
                    Text(DetailsViewModel.EditSection.company.title)
                        .font(Font.montserat(size: 14, weight: .medium))
                        .minimumScaleFactor(0.7)
                }
            }

            submenu(title: Constants.Strings.address, values: PostalAddressType.allCases) { type in
                viewModel.handle(.addPostalAddress(.init(id: UUID().uuidString, label: type.label, value: "")))
            }
        } label: {
            Text(Constants.Strings.other)
                .font(Font.montserat(size: 14, weight: .medium))
                .minimumScaleFactor(0.7)
        }
    }

    @ViewBuilder
    private func addButton() -> some View {
        Button(action: {
            withAnimation {
                viewModel.handle(.addPhoneNumber(.init(id: UUID().uuidString, label: PhoneNumberType.main.label, value: "", infoType: PhoneNumberType.mobile)))
            }
        }) {
            Text(Constants.Strings.add)
                .font(Font.montserat(size: 14, weight: .medium))
                .foregroundStyle(.appGreen)
        }
    }

    @ViewBuilder
    private func sectionHeader(text: String) -> some View {
        HStack {
            Text(text)
                .font(Font.montserat(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, <->16)
        .padding(.top, 32)
        .padding(.bottom, 18)
    }

    @ViewBuilder
    private func contactInfoSection() -> some View {
        if viewModel.state.presentedSections.contains(.contactInfo) {
            VStack(spacing: 0) {
                sectionHeader(text: Constants.Strings.contactInfo)

                VStack(spacing: 14) {
                    ForEach(viewModel.state.contactInfo) { info in
                        let text = Binding(
                            get: { info.value },
                            set: { viewModel.handle(.editContactMetod(oldValue: info, newValue: .init(id: info.id, label: info.label, value: $0, infoType: info.infoType))) }
                        )

                        ContactInfoTextField(
                            text: text,
                            promt: info.infoType?.prompt ?? Constants.Strings.unknown,
                            fieldType: info.infoType ?? UnknownType.unknown,
                            deleteAction: {
                                withAnimation {
                                    viewModel.handle(.deleteContactMetod(id: info.id, type: info.infoType ?? UnknownType.unknown))
                                }
                            },
                            onTypeChange: { viewModel.handle(.editContactMetod(oldValue: info, newValue: .init(id: info.id, label: $0.label, value: info.value, infoType: $0))) }
                        )
                    }
                }
                .onChange(of: viewModel.state.contactInfo) { _, newValue in
                    if newValue.isEmpty {
                        withAnimation {
                            viewModel.handle(.showSection(.contactInfo, false))
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func addressSection() -> some View {
        if viewModel.state.presentedSections.contains(.address) {
            VStack(spacing: 0) {
                sectionHeader(text: Constants.Strings.address)

                VStack(spacing: 14) {
                    ForEach(viewModel.state.contact.postalAddresses) { address in
                        let text = Binding(
                            get: { address.value },
                            set: { viewModel.handle(.editPostalAddress(newValue: .init(id: address.id, label: address.label, value: $0, infoType: address.infoType))) }
                        )

                        ContactInfoTextField(
                            text: text,
                            promt: address.infoType?.prompt ?? Constants.Strings.unknown,
                            fieldType: address.infoType ?? UnknownType.unknown,
                            deleteAction: {
                                withAnimation {
                                    viewModel.handle(.deletePostalAddress(id: address.id))
                                }
                            },
                            onTypeChange: { viewModel.handle(.editContactMetod(oldValue: address, newValue: .init(id: address.id, label: $0.label, value: address.value, infoType: $0))) }
                        )
                    }
                }
                .onChange(of: viewModel.state.contact.postalAddresses) { _, newValue in
                    if newValue.isEmpty {
                        withAnimation {
                            viewModel.handle(.showSection(.address, false))
                        }
                    }
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
            sectionHeader(text: Constants.Strings.socialMedia)

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
            get: { viewModel.state.contact.givenName ?? "" },
            set: { viewModel.handle(.editGivenName($0))
            }
        )
    }

    private var lastName: Binding<String> {
        Binding(
            get: { viewModel.state.contact.familyName ?? "" },
            set: { viewModel.handle(.editFamilyname($0))
            }
        )
    }

    private var company: Binding<String> {
        Binding(
            get: { viewModel.state.contact.organizationName ?? "" },
            set: { viewModel.handle(.editOrganizationName($0))
            }
        )
    }

    private struct Constants {
        enum Strings {
            // MARK: Menus
            static let phoneNumber = "Phone Number"
            static let emailAddress = "Email Address"
            static let other = "Other Info"

            // MARK: Sections
            static let contactInfo = "Contact Info"
            static let address = "Address"
            static let socialMedia = "Social Media"

            static let add = "Add"
            static let unknown = "Unknown"
        }
    }
}

extension Contact {
    static var testContact: Contact = .init(
        id: UUID().uuidString,
        givenName: "Mark",
        middleName: "A",
        familyName: "Reed",
        organizationName: "TestCo",
        phoneNumbers: [.init(id: "number", label: PhoneNumberType.home.label, value: "0123456789", infoType: PhoneNumberType.home)],
        emailAddresses: [.init(id: "email", label: EmailAddressType.home.label, value: "email@email.com", infoType: EmailAddressType.home)],
        postalAddresses: [.init(id: "postal", label: PostalAddressType.home.label, value: "test str. 9, 8600, Testvile", infoType: PostalAddressType.home)],
        urlAddresses: [.init(id: "url", label: URLAddressType.home.label, value: "www.test.com", infoType: URLAddressType.home)],
        socialProfiles: [],
        instantMessageAddresses: [],
        birthday: .now,
        imageData: UIImage(named: "avatar9x2")?.pngData(),
        imageDataAvailable: true,
        isFavorite: false
    )
}
