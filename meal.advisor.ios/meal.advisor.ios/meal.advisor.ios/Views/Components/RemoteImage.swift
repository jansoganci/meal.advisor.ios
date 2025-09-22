//
//  RemoteImage.swift
//  meal.advisor.ios
//
//  Image loader that uses Kingfisher if available, otherwise AsyncImage.
//

import SwiftUI

struct RemoteImage: View {
    let url: URL?
    let aspectRatio: CGFloat = 16.0/9.0

    var body: some View {
#if canImport(Kingfisher)
        RemoteImageKF(url: url, aspectRatio: aspectRatio)
#else
        RemoteImageAsync(url: url, aspectRatio: aspectRatio)
#endif
    }
}

#if canImport(Kingfisher)
import Kingfisher

private struct RemoteImageKF: View {
    let url: URL?
    let aspectRatio: CGFloat
    var body: some View {
        if let url {
            KFImage(url)
                .placeholder {
                    LoadingShimmer()
                        .aspectRatio(aspectRatio, contentMode: .fit)
                }
                .resizable()
                .scaledToFill()
                .transition(.opacity.animation(.easeInOut(duration: 0.3)))
                .aspectRatio(aspectRatio, contentMode: .fit)
                .clipped()
        } else {
            LoadingShimmer()
                .aspectRatio(aspectRatio, contentMode: .fit)
        }
    }
}
#endif

private struct RemoteImageAsync: View {
    let url: URL?
    let aspectRatio: CGFloat
    var body: some View {
        ZStack {
            LoadingShimmer()
                .aspectRatio(aspectRatio, contentMode: .fit)
                .accessibilityHidden(true)
            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        Color.clear
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .transition(.opacity.animation(.easeInOut(duration: 0.3)))
                    case .failure:
                        Image(systemName: "fork.knife")
                            .font(.title)
                            .foregroundColor(.primaryOrange)
                    @unknown default:
                        EmptyView()
                    }
                }
                .aspectRatio(aspectRatio, contentMode: .fit)
                .clipped()
            }
        }
    }
}

