//
//  RootView.swift
//  SwiftAccountBook
//
//  Created by 권성한 on 2/2/24.
//

import SwiftUI

struct RootView: View {
    
    @State private var showSignInView: Bool = false
    
    var body: some View {
        ZStack{
            NavigationStack {
                SettingsView(showSignInView: $showSignInView)
            }
        }
        .onAppear {
            let authuser = try? AuthenticationManager.shared.getAuthenticationUser()
            self.showSignInView = authuser == nil ? true : false
        }
        .fullScreenCover(isPresented: $showSignInView){
                NavigationStack {
                    AuthenticationView()
                }
            }
        }
    }

struct RootView_Previews : PreviewProvider {
    static var previews: some View {
        NavigationStack{
            RootView()
        }
    }
}
