//
//  SettingsView.swift
//  SwiftAccountBook
//
//  Created by 권성한 on 2/2/24.
//

import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    
    
    func signOut() throws {
        try AuthenticationManager.shared.signOut()
    }
}

struct SettingsView: View {
    
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        List{
            Button("로그아웃"){
                do {
                    try viewModel.signOut()
                    showSignInView = true
                } catch {
                    print(error)
                }
            }
        }
        .navigationTitle("설정")
    }
}

struct SettingsView_Previews : PreviewProvider {
    static var previews: some View{
        NavigationStack{
            SettingsView(showSignInView: .constant(false))
        }
    }
}
