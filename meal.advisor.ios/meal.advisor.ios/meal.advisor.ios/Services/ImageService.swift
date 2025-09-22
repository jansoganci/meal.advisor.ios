//
//  ImageService.swift
//  meal.advisor.ios
//
//  Lightweight image prefetching/caching wrapper.
//

import Foundation
#if canImport(Kingfisher)
import Kingfisher
#endif

final class ImageService {
    static let shared = ImageService()
    private init() {}

    func prefetch(url: URL?) async {
        guard let url else { return }
#if canImport(Kingfisher)
        let prefetcher = ImagePrefetcher(urls: [url])
        prefetcher.start()
#else
        // No-op when Kingfisher is not available
        _ = url
#endif
    }
}
