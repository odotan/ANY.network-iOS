//
//  SyncPhoneBookButton.swift
//  ANY network
//
//  Created by Rumen Ganev on 29.07.24.
//

import SwiftUI

struct SyncPhoneBookButton: View {
    private let action: () -> Void
    private let onDismiss: () -> Void

    init(action: @escaping () -> Void, onDismiss: @escaping () -> Void) {
        self.action = action
        self.onDismiss = onDismiss
    }

    var body: some View {
        Button(action: action) {
            Image(.syncPhonebookButton)
                .resizable()
                .frame(height: |165)
        }
        .frame(maxWidth: .infinity)
        .overlay(alignment: .topTrailing) {
            Button(action: onDismiss) {
                Circle()
                    .fill(.clear)
            }
            .frame(width: <->24, height: |24)
            .clipShape(Circle())

        }
        .padding(.horizontal, <->16)
    }
}

#Preview {
    SyncPhoneBookButton(action: { }, onDismiss: { })
}
