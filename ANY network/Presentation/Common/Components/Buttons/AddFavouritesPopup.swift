//
//  AddFavouritesPopup.swift
//  ANY network
//
//  Created by Rumen Ganev on 30.07.24.
//

import SwiftUI

struct AddFavouritesPopup: View {
    private let onDismiss: () -> Void

    init(onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
    }

    var body: some View {
        Image(.homePopup)
            .resizable()
            .frame(height: |111)
            .frame(maxWidth: .infinity)
            .onTapGesture(perform: onDismiss)
            .padding(.horizontal, <->16)
    }
}

#Preview {
    AddFavouritesPopup(onDismiss: { })
}
