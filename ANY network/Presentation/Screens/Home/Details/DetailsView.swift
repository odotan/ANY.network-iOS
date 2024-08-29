import SwiftUI

struct DetailsView: View {
    typealias CellView = View

    @StateObject var viewModel: DetailsViewModel
    @State private var avatarPossition: CGPoint = .zero
    @State private var avatarSize: CGSize = .zero
    @State private var scrollOffset: CGFloat = .zero

    var body: some View {
        VStack {
            GeometryReader { reader in
                let size = reader.size

                grid(size: size)

                if isEditing.wrappedValue {
                    scrollView(size: size)
                    
                    myAvatar(size: size)
                }
            }
        }
        .onChange(of: avatarPossition) { oldValue, newValue in
            print("Avatar", newValue)
        }
        .background { Color.appBackground }
        .ignoresSafeArea()
        .toolbar(.hidden)
        .backButton {
            viewModel.handle(.goBack)
        }
        .overlay(alignment: .top) {
            Text(isEditing.wrappedValue ? "Edit" : viewModel.state.contact.fullName)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.3)
                .lineLimit(2)
                .font(.montserat(size: 24, weight: .bold))
                .foregroundColor(.white)
                .frame(width: <->300)
        }
        .overlay(alignment: .topTrailing) {
            Button {
                withAnimation {
                    if isEditing.wrappedValue {
                        viewModel.handle(.save)
                    } else {
                        viewModel.handle(.starPressed)
                    }
                }
            } label: {
                if isEditing.wrappedValue {
                    Text("Save")
                        .foregroundColor(.appGreen)
                        .font(.montserat(size: 16, weight: .semibold))
                } else {
                    Image(viewModel.state.isFavorite ? .startFillIcon : .starIcon)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .padding(.horizontal, 8)
                }
            }
            .padding(.trailing, 8)
        }
        .alert(viewModel.state.actionPrompt?.title ?? "", isPresented: hasAlert, presenting: viewModel.state.actionPrompt) { action in
            Button(action: action.action) {
                Text("Call")
            }
            Button("Cancel", role: .cancel) {}
        } message: { action in
            Text(action.description)
        }
    }
    
    @ViewBuilder
    private func grid(size: CGSize) -> some View {
        let screenCenterHeight = size.height / 2

        DetailsPresentView(
            isEditing: isEditing,
            contact: {
                viewModel.state.contact
            },
            performAction: { action in
                withAnimation {
                    viewModel.handle(.performAction(action))
                }
            },
            cellDatasource: { cellItem, cellView in
                switch (cellItem.offsetCoordinate.row, cellItem.offsetCoordinate.col) {
                case (4, 2):
                    AnyView(
                        cellView
                            .sizeInfo(size: $avatarSize)
                            .captureCenterPoint { point in
                                avatarPossition = point
                            }
                            .opacity(isEditing.wrappedValue ? 0 : 1)
                    )
                default:
                    cellView
                }
            }
        )
        .opacity(
            isEditing.wrappedValue ? calculateHexagonOpacity(
                screenCenterHeight: screenCenterHeight,
                offset: scrollOffset
            ) : 1
        )
    }
    
    @ViewBuilder
    private func myAvatar(size: CGSize) -> some View {
        let screenCenterHeight = size.height / 2
        let scaleFactor = isEditing.wrappedValue ? mapCGFloat(
            value: scrollOffset,
            inputMin: -screenCenterHeight / 2.3,
            inputMax: -screenCenterHeight / 1.5,
            outputMin: 1,
            outputMax: 119 / avatarSize.height
        ) : 1
        
        AvatarHexCell(imageData: viewModel.state.contact.imageData, color: .appPurple)
            .frame(width: avatarSize.width, height: avatarSize.height)
            .clipShape(HexagonShape(cornerRadius: 6))
            .scaleEffect(scaleFactor, anchor: .center)
            .position(avatarPossition)
            .offset(y: 
                isEditing.wrappedValue ? (mapCGFloat(
                    value: scrollOffset,
                    inputMin: -screenCenterHeight / 2.3,
                    inputMax: -screenCenterHeight / 1.5,
                    outputMin: 0,
                    outputMax: 1
                ) * (avatarPossition.y - |173) * (-1)) : 0
            )
    }
    
    @ViewBuilder
    private func scrollView(size: CGSize) -> some View {
        let screenCenterHeight = size.height / 2

        VStack(spacing: 0) {
            Spacer()

            ScrollView {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: isEditing.wrappedValue ? size.height * 0.43 - 100 : size.height * 1)
                        .id("space")
                    
                    EditContactView(contact: viewModel.state.contact)
                        .frame(width: size.width, height: size.height)
                        .id("edit")
                        .background(.appBackground)
                        .background(alignment: .top) {
                            LinearGradient(colors: [.appBackground, .clear], startPoint: .bottom, endPoint: .top)
                                .frame(height: 140)
                                .offset(y: -140)
                        }
                }
                .background(
                    GeometryReader {
                        Color.clear.preference(key: ScrollOffsetPreferenceKey.self, value: $0.frame(in: .named("scroll")).minY)
                    }
                )
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                    scrollOffset = value > 0 ? 0 : value
                }
            }
            .overlay(alignment: .top) {
                LinearGradient(colors: [.appBackground, .appBackground, .clear], startPoint: .top, endPoint: .bottom)
                    .frame(height: 50)
                    .opacity(
                        isEditing.wrappedValue ? 1 - calculateHexagonOpacity(
                            screenCenterHeight: screenCenterHeight,
                            offset: scrollOffset
                        ) : 0
                    )
            }
            .scrollTargetLayout()
            .scrollTargetBehavior(.viewAligned)
            .scrollIndicators(.hidden)
            .scrollDisabled(!isEditing.wrappedValue)
            .frame(width: size.width, height: size.height / 1.4)
            .coordinateSpace(name: "scroll")
        }
        .frame(width: size.width, height: size.height)
        .opacity(isEditing.wrappedValue ? 1 : 0)
    }
    
    
    // MARK: - HexCellFunctions
    private func setCenterIconPossition(frame: CGRect) {
        avatarPossition = .init(x: frame.midX, y: frame.midY)
    }

    private func mapCGFloat(value: CGFloat, inputMin: CGFloat, inputMax: CGFloat, outputMin: CGFloat, outputMax: CGFloat) -> CGFloat {
        guard value <= inputMin else { return outputMin }
        guard value >= inputMax else { return outputMax }
       return (value - inputMin) * (outputMax - outputMin) / (inputMax - inputMin) + outputMin
     }

    private func calculateHexagonOpacity(screenCenterHeight: CGFloat, offset: CGFloat) -> Double {
        let offsetMap = mapCGFloat(value: offset, inputMin: 0, inputMax: -screenCenterHeight * 0.8, outputMin: 0, outputMax: 1)
        return 1.0 - offsetMap
    }

    private struct ScrollOffsetPreferenceKey: PreferenceKey {
        static var defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value += nextValue()
        }
    }

    // MARK: - Constants
    struct Constants {
        enum Strings {
            static let save = "Save"
            static let edit = "Edit"
        }
    }

    
    var hasAlert: Binding<Bool> {
        .init(
            get: { viewModel.state.actionPrompt != nil },
            set: { if !$0 { viewModel.handle(.presentPrompt(nil)) }  }
        )
    }
    
    var isEditing: Binding<Bool> {
        .init(
            get: { viewModel.state.isEditing },
            set: { viewModel.handle(.setIsEditing($0)) }
        )
    }
}
//
//#Preview {
//    DetailsView(viewModel: .init(
//        contact: Contact(id: "", givenName: "John", familyName: "Dembow", imageData: nil, imageDataAvailable: false, isFavorite: false),
//        coordinator: MainCoordinator())
//    )
//}
