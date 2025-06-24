import Foundation
import SwiftUI
import XMTPiOS

final class HiUHomeViewModel: ViewModel {
    @Published private(set) var state: State
    @Published var gridModel: HiUScrollableHexGridModel = .init()

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
            state.cellQueue[coordinate] = model
            gridModel.refresh()
            
        case .updateLastTap(let time, let cell):
            state.lastTapTime = time
            state.lastTappedCell = cell
            
        case .stateUpdated(let hexState, let cell):
            print("ViewModel: State update requested for \(cell.offsetCoordinate) to state: \(hexState)")
            if let model = state.cellQueue[cell.offsetCoordinate] {
                var new = model
                new.state = hexState
                if hexState == .timerStarted {
                    new.startedAt = Date.now
                }
                state.cellQueue[cell.offsetCoordinate] = new
            } else {
                var model = HexFlowerModel(state: hexState)
                if hexState == .timerStarted {
                    model.startedAt = Date.now
                }
                state.cellQueue[cell.offsetCoordinate] = model
                state.cellQueueOrder.append(cell.offsetCoordinate)
            }
            
            let allReady = self.state.cellQueue.filter { $0.value.state == .selected }
            let animating = self.state.cellQueue.filter { $0.value.state == .animationStarted }

            gridModel.refresh()

            // Use the first element from our ordered list that is in ready state
            if let next = state.cellQueueOrder.first(where: { allReady.keys.contains($0) }), animating.isEmpty {
                guard var model = self.state.cellQueue[next] else { return }
                model.state = .animationStarted
                state.cellQueue[next] = model
                gridModel.refresh()
            }
            
        case .details(let cell):
            guard state.selectedCell == nil else { return }

            state.selectedCell = cell
            Task { @MainActor in
                gridModel.zoomAndCenter(to: cell.offsetCoordinate, scale: 8)
            }
            gridModel.refresh()
            
        case .moveBack:
            gridModel.zoom(to: 1)
            state.selectedCell = nil
            
            Task { @MainActor in
                gridModel.recenter(paddingBottom: 100)
            }
            gridModel.scrollEnabled = true
            gridModel.refresh()
            
        case .recenter:
            gridModel.recenter(paddingBottom: 100)
            
        case .initializeXMTP:
            Task {
                do {
                    print("🔐 [HiUHomeViewModel] Initializing XMTP client...")
                    let client = try await createXMTPClientUseCase.createClient()
                    print("🔐 [HiUHomeViewModel] XMTP client initialized successfully!")
                    await MainActor.run {
                        state.xmtpClientInitialized = true
                    }
                    // Store FUser in Firebase
                    let user = XMTPUser(address: client.publicIdentity.identifier, inboxId: client.inboxID)
                    try await storeXMTPUserUseCase.execute(user: user)
                    print("✅ Stored XMTP user in Firebase: address=\(user.address), inboxId=\(user.inboxId)")
                } catch {
                    print("🔐 [HiUHomeViewModel] Failed to initialize XMTP client: \(error)")
                    await MainActor.run {
                        state.xmtpClientError = error.localizedDescription
                    }
                }
            }
            
        case .testClearAndInitialize:
            Task {
                do {
                    print("🔐 [HiUHomeViewModel] Clearing XMTP data and reinitializing...")
                    // Clear all XMTP data
                    createXMTPClientUseCase.clearAllData()
                    // Try to initialize again
                    try await createXMTPClientUseCase.createClient()
                    print("🔐 [HiUHomeViewModel] XMTP client reinitialized successfully!")
                    await MainActor.run {
                        state.xmtpClientInitialized = true
                        state.xmtpClientError = nil
                    }
                } catch {
                    print("🔐 [HiUHomeViewModel] Failed to reinitialize XMTP client: \(error)")
                    await MainActor.run {
                        state.xmtpClientError = error.localizedDescription
                    }
                }
            }
            
        case .listConversations:
            Task {
                do {
                    print("🔐 [HiUHomeViewModel] Listing conversations...")
                    let conversations = try await xmtpConversationUseCase.listConversations()
                    print("🔐 [HiUHomeViewModel] Found \(conversations.count) conversations")
                    await MainActor.run {
                        self.state.conversations = conversations
                        self.state.conversationError = nil
                    }
                } catch {
                    print("🔐 [HiUHomeViewModel] Failed to list conversations: \(error)")
                    await MainActor.run {
                        self.state.conversationError = error.localizedDescription
                    }
                }
            }
            
        case .startConversationStream:
            Task {
                do {
                    print("🔐 [HiUHomeViewModel] Starting conversation stream...")
                    try await xmtpConversationUseCase.streamConversations(
                        onConversation: { [weak self] conversation in
                            Task { @MainActor in
                                print("🔐 [HiUHomeViewModel] New conversation received: \(conversation.topic)")
                                self?.state.conversations.append(conversation)
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
            
        case .startMessageStream:
            Task {
                do {
                    print("🔐 [HiUHomeViewModel] Starting message stream...")
                    try await xmtpConversationUseCase.streamAllMessages(
                        onMessage: { [weak self] message in
                            Task { @MainActor in
                                print("🔐 [HiUHomeViewModel] New message received")
                                self?.state.messages.append(message)
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
            
        case .stopStreams:
            print("🔐 [HiUHomeViewModel] Stopping all streams...")
            xmtpConversationUseCase.stopStreams()
            
        case .storeXMTPUser(let user):
            Task {
                do {
                    try await storeXMTPUserUseCase.execute(user: user)
                    print("✅ Stored XMTP user: address=\(user.address), inboxId=\(user.inboxId)")
                } catch {
                    print("❌ Failed to store XMTP user: \(error)")
                }
            }
            
        case .fetchAllXMTPUsers:
            Task {
                do {
                    let users = try await fetchAllXMTPUsersUseCase.execute()
                    state.xmtpUsers = users
                    print("✅ Fetched XMTP users: \(users)")
                    
                    
                } catch {
                    print("❌ Failed to fetch XMTP users: \(error)")
                }
            }
        case .sendMessage(inboxId: let inboxId, content: let content):
            Task {
                do {
                    print("🔐 [HiUHomeViewModel] Sending message to inboxId: \(inboxId)...")
                    try await xmtpConversationUseCase.sendMessage(inboxId: inboxId, content: content)
                    print("🔐 [HiUHomeViewModel] Message sent successfully!")
                } catch {
                    print("🔐 [HiUHomeViewModel] Failed to send message: \(error)")
                }
            }
        }
    }
}
