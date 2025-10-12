// TEST: Static Image URL Rendering
// Bu dosyayı çalıştırarak image rendering'in çalıştığını doğrulayabilirsiniz

import SwiftUI

struct TestImageView: View {
    // ✅ Bilinen çalışan bir Unsplash image URL'si
    let testURL = URL(string: "https://images.unsplash.com/photo-1546069901-ba9599a7e63c")!
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Image Rendering Test")
                .font(.title)
            
            // Test 1: RemoteImage component
            RemoteImage(url: testURL)
                .frame(height: 200)
            
            Text("✅ Eğer yukarıda yemek fotoğrafı görüyorsan, RemoteImage çalışıyor!")
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding()
    }
}

#Preview {
    TestImageView()
}

