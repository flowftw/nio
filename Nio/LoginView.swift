import SwiftUI

struct LoginView: View {
    @EnvironmentObject var mxStore: MatrixStore

    @State private var username = ""
    @State private var password = ""
    @State private var homeserver = "matrix.org"

    @State private var showingRegisterView = false

    var loginEnabled: Bool {
        guard !username.isEmpty && !password.isEmpty else { return false }
        guard let hsURL = URL(string: homeserver) else { return false }
        guard !hsURL.absoluteString.isEmpty else { return false }
        return true
    }

    var body: some View {
        VStack {
            Spacer()
            LoginTitleView()

            Spacer()
            LoginForm(username: $username, password: $password, homeserver: $homeserver)

            Button(action: {
                self.mxStore.login(username: self.username,
                                   password: self.password,
                                   homeserver: URL(string: "https://matrix.org")!)
            }, label: {
                Text("Log in")
                    .font(.system(size: 18))
                    .bold()
            })
            .padding([.top, .bottom], 30)
            .disabled(!loginEnabled)

            Button(action: {
                self.showingRegisterView.toggle()
            }, label: {
                Text("Register a new account on matrix.org").font(.footnote)
            })

            Spacer()
        }
        .sheet(isPresented: $showingRegisterView) {
            Text("Registering for new accounts is not yet implemented.")
        }
    }
}

private struct LoginTitleView: View {
    var body: some View {
        let purpleTitle = Text("Nio").foregroundColor(.purple)

        return VStack {
            (Text("👋 Welcome to ") + purpleTitle + Text("!"))
                .font(.title)
                .bold()
            Text("Log in to your account below to get started.")
        }
    }
}

private struct LoginForm: View {
    @Binding var username: String
    @Binding var password: String
    @Binding var homeserver: String

    @ObservedObject private var keyboard = KeyboardGuardian(textFieldCount: 1)

    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Text("Username")
                    .font(Font.body.smallCaps())
                    .foregroundColor(.purple)
                TextField("t.anderson", text: $username)
            }
            .padding([.horizontal, .bottom])

            HStack(alignment: .center) {
                Text("Password")
                    .font(Font.body.smallCaps())
                    .foregroundColor(.purple)
                SecureField("********", text: $password)
            }
            .padding([.horizontal, .bottom])

            HStack(alignment: .center) {
                Text("Homeserver")
                    .font(Font.body.smallCaps())
                    .foregroundColor(.purple)
                TextField("matrix.org", text: $homeserver,
                          onEditingChanged: { if $0 { self.keyboard.showField = 0 }})
                    .background(GeometryGetter(rect: $keyboard.rects[0]))
                    .keyboardType(.URL)
            }
            .padding(.horizontal)
        }
        .offset(y: keyboard.slide).animation(.easeInOut(duration: 0.25))
        .onAppear { self.keyboard.addObserver() }
        .onDisappear { self.keyboard.removeObserver() }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(MatrixStore())
    }
}