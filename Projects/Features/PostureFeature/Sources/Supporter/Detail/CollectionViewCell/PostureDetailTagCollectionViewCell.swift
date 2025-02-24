import UIKit

import SnapKit
import Then

import DSKit
import Domain

public class PostureDetailTagCollectionViewCell: UICollectionViewCell {

    static let identifier: String = "PostureDetailTagCollectionViewCell"

    private var tagLabel = MGTagLabel()

    private func layout() {
        contentView.addSubviews([tagLabel])

        tagLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

public extension PostureDetailTagCollectionViewCell {
    func setup(with text: String) {
        tagLabel.updateData(text: text)

        layout()
    }
}
