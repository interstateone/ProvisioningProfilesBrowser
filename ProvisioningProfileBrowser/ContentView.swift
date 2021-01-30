import SwiftUI

struct ContentView: View {
    @EnvironmentObject var profilesManager: ProvisioningProfilesManager
    @State private var selectedProfile: ProvisioningProfile.ID?
    
    var body: some View {
        VSplitView {
            ProfilesList(data: $profilesManager.visibleProfiles, selection: $selectedProfile)
            
            if let selectedProfile = selectedProfile,
               let url = profilesManager.visibleProfiles.first(where: { $0.id == selectedProfile })?.url {
                QuickLookPreview(url: url)
            } else {
                Color(.windowBackgroundColor)
            }
        }
        .onAppear(perform: profilesManager.reload)
        .frame(minWidth: 300, minHeight: 300)
        .alert(isPresented: $profilesManager.error.isNotNil) {
            Alert(
                title: Text("Error"),
                message: Text(profilesManager.error!.localizedDescription),
                dismissButton: Alert.Button.default(Text("OK"))
            )
        }
    }    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
