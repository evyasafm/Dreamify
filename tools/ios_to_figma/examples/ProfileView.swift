import SwiftUI

struct ProfileView: View {
    var body: some View {
        VStack(spacing: 20) {
            // Profile Image
            Circle()
                .foregroundColor(.gray)
                .frame(width: 120, height: 120)

            // Name
            Text("John Doe")
                .font(.title)
                .bold()

            // Bio
            Text("iOS Developer & Designer")
                .font(.subheadline)
                .foregroundColor(.gray)

            // Stats
            HStack(spacing: 30) {
                VStack {
                    Text("128")
                        .font(.headline)
                        .bold()
                    Text("Posts")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                VStack {
                    Text("2.5K")
                        .font(.headline)
                        .bold()
                    Text("Followers")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                VStack {
                    Text("342")
                        .font(.headline)
                        .bold()
                    Text("Following")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(.top, 20)

            // Action Button
            Button(action: {}) {
                Text("Edit Profile")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(Color.blue)
                    .cornerRadius(25)
            }

            Spacer()
        }
        .padding()
    }
}
