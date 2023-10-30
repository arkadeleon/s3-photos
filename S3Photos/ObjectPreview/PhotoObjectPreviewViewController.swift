//
//  PhotoObjectPreviewViewController.swift
//  S3Photos
//
//  Created by Leon Li on 2023/10/16.
//

import UIKit

class PhotoObjectPreviewViewController: UIViewController {

    let manager: S3ObjectManager
    let object: S3Object

    var scrollView: UIScrollView!
    var previewView: UIImageView!
    var thumbnailView: UIImageView!

    private var previewTask: Task<UIImage?, Error>?

    init(manager: S3ObjectManager, object: S3Object) {
        self.manager = manager
        self.object = object

        super.init(nibName: nil, bundle: nil)

        title = object.name
    }

    deinit {
        previewTask?.cancel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        scrollView = UIScrollView(frame: view.bounds)
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.delegate = self
        view.addSubview(scrollView)

        previewView = UIImageView()
        scrollView.addSubview(previewView)

        thumbnailView = UIImageView(frame: view.bounds)
        thumbnailView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        thumbnailView.contentMode = .scaleAspectFit
        view.addSubview(thumbnailView)

        Task {
            for try await thumbnail in manager.thumbnailStreamForObject(object) {
                thumbnailView.image = thumbnail
            }

            previewTask = manager.previewTask(for: object)
            if let preview = try await previewTask?.value {
                thumbnailView.isHidden = true

                previewView.image = preview
                previewView.frame = CGRect(x: 0, y: 0, width: preview.size.width, height: preview.size.height)
                scrollView.contentSize = preview.size

                updateZoomScale(with: preview.size)
                centerScrollViewContents()
            }
        }
    }

    private func updateZoomScale(with imageSize: CGSize) {
        let scrollViewFrame = scrollView.bounds

        let scaleWidth = scrollViewFrame.size.width / imageSize.width
        let scaleHeight = scrollViewFrame.size.height / imageSize.height
        let minScale = min(scaleWidth, scaleHeight)

        scrollView.minimumZoomScale = minScale;
        scrollView.maximumZoomScale = minScale * 16

        scrollView.zoomScale = scrollView.minimumZoomScale;
    }

    private func centerScrollViewContents() {
        var horizontalInset: CGFloat = 0
        var verticalInset:CGFloat = 0

        if scrollView.contentSize.width < scrollView.bounds.width {
            horizontalInset = (scrollView.bounds.width - scrollView.contentSize.width) * 0.5
        }

        if scrollView.contentSize.height < scrollView.bounds.height {
            verticalInset = (scrollView.bounds.height - scrollView.contentSize.height) * 0.5
        }

        scrollView.contentInset = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
    }
}

extension PhotoObjectPreviewViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        previewView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerScrollViewContents()
    }
}
