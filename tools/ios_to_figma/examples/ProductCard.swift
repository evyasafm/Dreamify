import SwiftUI

struct ProductCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Product Image
            RoundedRectangle(cornerRadius: 15)
                .foregroundColor(.gray.opacity(0.2))
                .frame(height: 200)
                .overlay(
                    Image(systemName: "photo")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                )

            // Product Title
            Text("Premium Headphones")
                .font(.headline)
                .bold()

            // Description
            Text("High-quality wireless headphones with noise cancellation")
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(2)

            // Rating
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.caption)
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.caption)
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.caption)
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.caption)
                Image(systemName: "star")
                    .foregroundColor(.gray)
                    .font(.caption)
                Text("(4.0)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            // Price and Button
            HStack {
                VStack(alignment: .leading) {
                    Text("$299.99")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.blue)
                }

                Spacer()

                Button(action: {}) {
                    Text("Add to Cart")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}
