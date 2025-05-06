import SwiftUI

struct SettingsView: View {
    @State private var notificationsEnabled = true
    
    var body: some View {
        ZStack {
            Color(red: 0.0, green: 0.1, blue: 0.0).ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Settings")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                Image("settings_header")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                
                VStack(spacing: 10) {
                  
                    HStack {
                        Text("Notifications")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                        Toggle("", isOn: $notificationsEnabled)
                            .labelsHidden()
                            .toggleStyle(SwitchToggleStyle(tint: Color.yellow))
                    }
                    .padding()
                    .background(Color.green.opacity(0.3))
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
                    
                    SettingsButton(title: "Privacy Policy", url: "https://www.termsfeed.com/live/53545c1a-e670-445c-82a5-3e5369e6d887")
                    SettingsButton(title: "About the Developers", url: "https://landing.flycricket.io/frootynator-juice-master/75be3873-3d43-4195-a294-a02f48d24473/?t=1746474073")
                }
                Spacer()
            }
        }
    }
}

struct SettingsButton: View {
    let title: String
    let url: String
    
    var body: some View {
        Button(action: {
            if let link = URL(string: url) {
                UIApplication.shared.open(link)
            }
        }) {
            HStack {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.black.opacity(0.2))
            .cornerRadius(10)
            .padding(.horizontal, 20)
        }
        .navigationBarHidden(true)
    }
}
