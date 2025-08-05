import Foundation
import SwiftUI
import XMTPiOS

final class HiUHomeViewModel: ViewModel {
    @Published private(set) var state: State
    @Published var gridModel: HiUScrollableHexGridModel = .init()
    @Published var flyingPointsCoordinator = FlyingPointsCoordinator()

    private let coordinator: MainCoordinatorProtocol
    private let createXMTPClientUseCase: CreateXMTPClientUseCase
    private let xmtpConversationUseCase: XMTPConversationUseCase
    private let storeXMTPUserUseCase: StoreXMTPUserUseCase
    private let fetchAllXMTPUsersUseCase: FetchAllXMTPUsersUseCase
    
    init(coordinator: MainCoordinatorProtocol, createXMTPClientUseCase: CreateXMTPClientUseCase, xmtpConversationUseCase: XMTPConversationUseCase, storeXMTPUserUseCase: StoreXMTPUserUseCase, fetchAllXMTPUsersUseCase: FetchAllXMTPUsersUseCase) {
        self.state = State()
        self.coordinator = coordinator
        self.createXMTPClientUseCase = createXMTPClientUseCase
        self.xmtpConversationUseCase = xmtpConversationUseCase
        self.storeXMTPUserUseCase = storeXMTPUserUseCase
        self.fetchAllXMTPUsersUseCase = fetchAllXMTPUsersUseCase
    }
    
    func handle(_ event: Event) {
        switch event {
        case .setCellState(let coordinate, let model):
            break
//            state.cellQueue[coordinate] = model
//            gridModel.refresh()
            
        case .updateLastTap(let time, let cell):
            state.lastTapTime = time
            state.lastTappedCell = cell
            
        case .stateUpdated(let hexState, let cell):
            handleStateUpdated(hexState: hexState, cell: cell)
            
        case .details(let cell):
            handleDetails(cell: cell)
            
        case .moveBack:
            handleMoveBack()
            
        case .recenter:
            gridModel.recenter(paddingBottom: 100)
            
        case .initializeXMTP:
            handleInitializeXMTP()
            
        case .listConversations:
            handleListConversations()
            
        case .startConversationStream:
            handleStartConversationStream()
            
        case .startMessageStream:
            handleStartMessageStream()
            
        case .stopStreams:
            print("🔐 [HiUHomeViewModel] Stopping all streams...")
            xmtpConversationUseCase.stopStreams()

        case .sendMessage(let user):
            handleSendMessage(user: user)

        case .storeXMTPUser(let user):
            handleStoreXMTPUser(user: user)
            
        case .fetchAllXMTPUsers:
            handleFetchAllXMTPUsers()
        }
    }
    
    // MARK: - Private Methods
    
    private func handleStateUpdated(hexState: HexFlowerState, cell: HexCell) {
        print("ViewModel: State update requested for \(cell.offsetCoordinate) to state: \(hexState)")
        try? HapticService.shared.perform()
        
        if var existingModel = state.cellQueue[cell.offsetCoordinate] {
            existingModel.state = hexState
            if hexState == .timerStarted {
                handleTimerStarted(for: cell.offsetCoordinate, model: existingModel)
            } else {
                state.cellQueue[cell.offsetCoordinate] = existingModel
            }
        }// else {
//            createNewCellModel(for: coordinate, with: hexState)
//        }

        let readyCells = state.cellQueue.filter { $0.value.state == .selected }
        let animatingCells = state.cellQueue.filter { $0.value.state == .animationStarted }
        
        // Start animation for the first ready cell if no animations are currently running
        if let nextReadyCoordinate = state.cellQueueOrder.first(where: { readyCells.keys.contains($0) }),
           animatingCells.isEmpty {
            startAnimation(for: nextReadyCoordinate)
        }
        
        gridModel.refresh()
    }
    
    private func handleTimerStarted(for coordinate: OffsetCoordinate, model: HexFlowerModel) {
        var updatedModel = model
        state.cellQueue[coordinate] = updatedModel
        
        // Send message when timer starts
        handle(.sendMessage(model.user))
    }
    
//    private func createNewCellModel(for coordinate: OffsetCoordinate, with hexState: HexFlowerState) {
//        var model = HexFlowerModel(user: <#XMTPUser#>, state: hexState)
//        if hexState == .timerStarted {
//            model.startedAt = Date.now
//        }
//        state.cellQueue[coordinate] = model
//        state.cellQueueOrder.append(coordinate)
//    }
    
    private func startAnimation(for coordinate: OffsetCoordinate) {
        guard var model = state.cellQueue[coordinate] else { return }
        model.state = .animationStarted
        state.cellQueue[coordinate] = model
    }
    
    private func handleDetails(cell: HexCell) {
        guard state.selectedCell == nil else { return }

        state.selectedCell = cell
        Task { @MainActor in
            gridModel.zoomAndCenter(to: cell.offsetCoordinate, scale: 8)
        }
        gridModel.refresh()
    }
    
    private func handleMoveBack() {
        gridModel.zoom(to: 1)
        state.selectedCell = nil
        
        Task { @MainActor in
            gridModel.recenter(paddingBottom: 100)
        }
        gridModel.scrollEnabled = true
        gridModel.refresh()
    }
    
    private func handleInitializeXMTP() {
        Task {
            do {
                print("🔐 [HiUHomeViewModel] Initializing XMTP client...")
                let client = try await createXMTPClientUseCase.createClient()

                print("🔐 [HiUHomeViewModel] XMTP client initialized successfully!")
                await MainActor.run {
                    state.clientAddress = client.publicIdentity.identifier
                    state.xmtpClientInitialized = true
                }
                // Store FUser in Firebase
                let user = XMTPUser(address: client.publicIdentity.identifier, inboxId: client.inboxID)
                try await storeXMTPUserUseCase.execute(user: user)
                print("✅ Stored XMTP user in Firebase: address=\(user.address), inboxId=\(user.inboxId)")

                handle(.fetchAllXMTPUsers)
                handle(.listConversations)
                handle(.startConversationStream)
                handle(.startMessageStream)
            } catch {
                print("🔐 [HiUHomeViewModel] Failed to initialize XMTP client: \(error)")
                
                await MainActor.run {
                    state.xmtpClientError = error.localizedDescription
                }
            }
        }
    }
    
    private func handleListConversations() {
        Task {
            do {
                print("🔐 [HiUHomeViewModel] Listing conversations...")
                let conversations = try await xmtpConversationUseCase.listConversations()
                print("🔐 [HiUHomeViewModel] Found \(conversations.count) conversations")
                
                let messages = await withTaskGroup(of: XMTPMessage?.self) { group in
                    for conversation in conversations {
                        group.addTask {
                            let list = try? await conversation.messages(limit: 1)
                            let last = list?.last
                            return last?.xmtpMessage
                        }
                    }
                    
                    var results: [XMTPMessage] = []
                    for await result in group {
                        if let message = result {
                            results.append(message)
                        }
                    }
                    return results
                }
                
                await MainActor.run {
                    self.state.messages = messages
                    self.state.conversationError = nil
                    
                    updateModels()
                }
            } catch {
                print("🔐 [HiUHomeViewModel] Failed to list conversations: \(error)")
                await MainActor.run {
                    self.state.conversationError = error.localizedDescription
                }
            }
        }
    }
    
    private func handleStartConversationStream() {
        Task {
            do {
                print("🔐 [HiUHomeViewModel] Starting conversation stream...")
                try await xmtpConversationUseCase.streamConversations(
                    onConversation: { [weak self] conversation in
                        Task { @MainActor in
                            print("🔐 [HiUHomeViewModel] New conversation received: \(conversation.topic)")
                            let list = try? await conversation.messages(limit: 1)
                            let last = list?.last
                            if let msg = last?.xmtpMessage {
                                self?.state.messages.append(msg)

                                self?.updateModels()
                            }
                        }
                    },
                    onError: { [weak self] error in
                        Task { @MainActor in
                            print("🔐 [HiUHomeViewModel] Conversation stream error: \(error)")
                            self?.state.conversationError = error.localizedDescription
                        }
                    }
                )
            } catch {
                print("🔐 [HiUHomeViewModel] Failed to start conversation stream: \(error)")
                await MainActor.run {
                    self.state.conversationError = error.localizedDescription
                }
            }
        }
    }
    
    private func handleStartMessageStream() {
        Task {
            do {
                print("🔐 [HiUHomeViewModel] Starting message stream...")
                try await xmtpConversationUseCase.streamAllMessages(
                    onMessage: { [weak self] message in
                        Task { @MainActor in
                            print("🔐 [HiUHomeViewModel] New message received")
                            if let msg = message.xmtpMessage {
                                self?.state.messages.append(msg)
                                
                                self?.updateModels()
                            }
                        }
                    },
                    onError: { [weak self] error in
                        Task { @MainActor in
                            print("🔐 [HiUHomeViewModel] Message stream error: \(error)")
                            self?.state.messageError = error.localizedDescription
                        }
                    }
                )
            } catch {
                print("🔐 [HiUHomeViewModel] Failed to start message stream: \(error)")
                await MainActor.run {
                    self.state.messageError = error.localizedDescription
                }
            }
        }
    }
    
    private func handleSendMessage(user: XMTPUser) {
        Task {
            do {
                guard let myAddress = state.clientAddress else { return }

                print("🔐 [HiUHomeViewModel] Sending message to inboxId: \(user.address)...")
                let message = XMTPMessage(
                    id: UUID(),
                    hiUPoints: 1,
                    from: myAddress,
                    to: user.address,
                    toInboxId: user.inboxId,
                    latestEthereumBlockNumber: 0,
                    blockHash: "",
                    blockUnixTime: 0,
                    messageCreationStartUnixTime: Int(Date.now.timeIntervalSince1970),
                    replyToAddress: myAddress,
                    salt: ""
                )

                try await xmtpConversationUseCase.send(message: message)
                
                self.state.messages.append(message)
                updateModels()
                print("🔐 [HiUHomeViewModel] Message sent successfully!")
            } catch {
                print("🔐 [HiUHomeViewModel] Failed to send message: \(error)")
            }
        }
    }
    
    private func handleStoreXMTPUser(user: XMTPUser) {
        Task {
            do {
                try await storeXMTPUserUseCase.execute(user: user)
                print("✅ Stored XMTP user: address=\(user.address), inboxId=\(user.inboxId)")
            } catch {
                print("❌ Failed to store XMTP user: \(error)")
            }
        }
    }
    
    private func handleFetchAllXMTPUsers() {
        Task {
            do {
                let users = try await fetchAllXMTPUsersUseCase.execute()
                state.xmtpUsers = users.filter { $0.address != state.clientAddress }
                
                updateModels()
                print("✅ Fetched XMTP users: \(users)")
            } catch {
                print("❌ Failed to fetch XMTP users: \(error)")
            }
        }
    }
    
    private func updateModels() {
        guard let userList = state.xmtpUsers else { return }
        
        state.cellQueueOrder.removeAll()

        for (index, user) in userList.enumerated() {
            guard index < gridModel.gridItems.count else { continue }

            let coordinate = gridModel.gridItems[index].offsetCoordinate
            var message: XMTPMessage?
            var isLastMe: Bool = false
            if let msg = self.state.messages.last(where: { $0.from == user.address || $0.to == user.address }) {
                message = msg
                isLastMe = user.address == msg.to
                
                print("!!! New inteerval", message!.messageCreationStartUnixTime, Date.now.timeIntervalSince1970)
            }

            let model = HexFlowerModel(
                user: user,
                message: message,
                state: message != nil ? .timerStarted : .initial,
                isLastMe: isLastMe
            )
            state.cellQueue[coordinate] = model
            state.cellQueueOrder.append(coordinate)
        }
        
        gridModel.refresh()
        try? HapticService.shared.perform()
    }
}


extension DecodedMessage {
    var xmtpMessage: XMTPMessage? {
        guard let bodyStr = try? body else { return nil }
        
        do {
            let jsonData = bodyStr.data(using: .utf8) ?? Data()
            let message = try JSONDecoder().decode(XMTPMessage.self, from: jsonData)
            return message
        } catch {
            print("🔐 [DecodedMessage] Failed to decode XMTPMessage from body: \(error)")
            return nil
        }
    }
}
