import SwiftUI

struct EditContactView: View {
    @ObservedObject var viewModel: EditContactViewModel

    //    init(viewModel: EditContactViewModel) {
    //        _viewModel = StateObject(wrappedValue: viewModel)
    //    }

    // MARK: - Main View
    var body: some View {
        GeometryReader { reader in
            ScrollView {
                Spacer().frame(height: 50)

                personalInfoSection()
                    .padding(.top, |20)

                contactInfoSection()

                addressSection()
//                    .padding(.bottom, 30)

                addSectionMenu()
                    .padding(.vertical, 20)
            }
            .scrollIndicators(.never)
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
        let avaliableFieldsToAdd = DetailsViewModel.EditSection.allCases.filter {
            !(viewModel.state.presentedSections.contains(.company) && $0 == .company) && $0 != .socialMedia
        }

        Menu {
            VStack {
                ForEach(avaliableFieldsToAdd, id: \.hashValue) { section in
                    Button(action: {
                        withAnimation {
                            switch section {
                            case .contactInfo:
                                viewModel.handle(.addPhoneNumber(.init(id: UUID().uuidString, label: LabeledValueLabelType.mobile.value, value: "")))
                            case .address:
                                viewModel.handle(.addPostalAddress(.init(id: UUID().uuidString, label: "", value: "")))
                            case .company:
                                viewModel.handle(.showSection(section, true))
                            default:
                                return
                            }
                            viewModel.handle(.showSection(section, true))
                        }
                    }) {
                        Text(section.title)
                            .font(Font.montserat(size: 14, weight: .medium))
                            .foregroundStyle(.appGreen)
                            .minimumScaleFactor(0.7)
                    }
                }
            }
        } label: {
            Text("Add")
                .font(Font.montserat(size: 14, weight: .medium))
                .foregroundStyle(.appGreen)
                .frame(width: <->80, height: 40)
        }
    }

    @ViewBuilder
    private func addButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text("Add")
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
                sectionHeader(text: "Contact Info")

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
                            deleteAction: {
                                withAnimation {
                                    viewModel.handle(.deleteContactMetod(id: info.id, type: info.labelType))
                                }
                            },
                            onTypeChange: { viewModel.handle(.editContactMetod(id: info.id, newValue: .init(id: info.id, label: $0.value, value: info.value))) }
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
                sectionHeader(text: "Address")

                VStack(spacing: 14) {
                    ForEach(viewModel.state.contact.postalAddresses) { address in
                        let text = Binding(
                            get: { address.value },
                            set: { viewModel.handle(.editPostalAddress(id: address.id, newValue: .init(id: address.id, label: address.label, value: $0))) }
                        )

                        HexagonTextField(
                            text: text,
                            promt: "Address",
                            deleteAction: {
                                withAnimation {
                                    viewModel.handle(.deletePostalAddress(id: address.id))
                                }
                            }
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
