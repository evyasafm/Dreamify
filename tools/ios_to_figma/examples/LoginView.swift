import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        VStack(spacing: 25) {
            // Logo
            Image(systemName: "lock.shield")
                .font(.system(size: 80))
                .foregroundColor(.blue)

            // Title
            Text("Welcome Back")
                .font(.largeTitle)
                .bold()

            Text("Sign in to continue")
                .font(.subheadline)
                .foregroundColor(.gray)

            // Input Fields
            VStack(spacing: 15) {
                // Email field placeholder
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color.gray.opacity(0.1))
                    .frame(height: 50)
                    .overlay(
                        Text("Email")
                            .foregroundColor(.gray)
                    )

                // Password field placeholder
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color.gray.opacity(0.1))
                    .frame(height: 50)
                    .overlay(
                        Text("Password")
                            .foregroundColor(.gray)
                    )
            }
            .padding(.horizontal)

            // Login Button
            Button(action: {}) {
                Text("Sign In")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(Color.blue)
                    .cornerRadius(15)
            }
            .padding(.horizontal)

            // Forgot Password
            Button(action: {}) {
                Text("Forgot Password?")
                    .font(.footnote)
                    .foregroundColor(.blue)
            }

            Spacer()

            // Sign Up
            HStack {
                Text("Don't have an account?")
                    .foregroundColor(.gray)
                Button(action: {}) {
                    Text("Sign Up")
                        .foregroundColor(.blue)
                        .bold()
                }
            }
        }
        .padding()
    }
}
